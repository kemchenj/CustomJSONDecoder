//
//  Parser.swift
//  JSONCoder
//
//  Created by kemchenj on 20/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

import struct Foundation.Data

#if os(Linux)
    import func SwiftGlibc.C.math.pow
#else
    import func Darwin.C.math.pow
#endif

final class JSONParser {
    
    struct Option: OptionSet {
        public let rawValue: UInt8
        public init (rawValue: UInt8) { self.rawValue = rawValue }
        
        public static let omitNulls      = Option(rawValue: 0b0001)
        public static let allowFragments = Option(rawValue: 0b0010)
    }
    
    private let omitNulls: Bool

    private var pointer: UnsafePointer<UTF8.CodeUnit>
    private var buffer: UnsafeBufferPointer<UTF8.CodeUnit>
    
    private var stringBuffer: [UTF8.CodeUnit] = []
    
    private init(bufferPointers: UnsafeBufferPointer<UTF8.CodeUnit>, options: Option) throws {
        guard let pointer = bufferPointers.baseAddress, pointer != bufferPointers.endAddress else {
            throw Error(byteOffset: 0, reason: .emptyStream)
        }
        
        self.buffer = bufferPointers
        self.pointer = pointer
        self.omitNulls = options.contains(.omitNulls)
    }
}

extension JSONParser {
    
    static func parse(_ data: Data, options: Option = []) throws -> JSON {
        return try data.withUnsafeBytes { pointer in
            return try parse(UnsafeBufferPointer(start: pointer, count: data.count), options: options)
        }
    }
    
    static func parse(_ data: [UTF8.CodeUnit], options: Option = []) throws -> JSON {
        return try data.withUnsafeBufferPointer { buffer in
            return try parse(buffer, options: options)
        }
    }
    
    static func parse(_ string: String, options: Option = []) throws -> JSON {
        return try parse(Array(string.utf8), options: options)
    }
    
    static func parse(_ buffer: UnsafeBufferPointer<UTF8.CodeUnit>, options: Option = []) throws -> JSON {
        let parser = try JSONParser(bufferPointers: buffer, options: options)
        
        do {
            try parser.skipWhitespace()
            
            let rootValue = try parser.parseValue()
            
            if !options.contains(.allowFragments) {
                switch rootValue {
                case .array, .object: break
                default: throw Error.Reason.fragmentedJSON
                }
            }
            
            try parser.skipWhitespace()
            
            guard parser.pointer == parser.buffer.endAddress else { throw Error.Reason.invalidSyntax }
            
            return rootValue
        } catch let error as Error.Reason {
            throw Error(byteOffset: parser.buffer.baseAddress!.distance(to: parser.pointer), reason: error)
        }
    }
}

private extension JSONParser {
    
    func peek(aheadBy n: Int = 0) -> UTF8.CodeUnit? {
        let shiftedPointer = pointer.advanced(by: n)
        guard shiftedPointer < buffer.endAddress else {
            return nil
        }
        return shiftedPointer.pointee
    }
    
    @discardableResult
    func pop() -> UTF8.CodeUnit {
        assert(pointer != buffer.endAddress)
        defer { pointer = pointer.advanced(by: 1) }
        return pointer.pointee
    }
    
    func hasPrefix(_ prefix: [UTF8.CodeUnit]) -> Bool {
        for (index, byte) in prefix.enumerated() {
            guard byte == peek(aheadBy: index) else { return false }
        }
        return true
    }
}

private extension JSONParser {
    
    func parseValue() throws -> JSON {
        assert(!pointer.pointee.isWhiteSpace)
        
        defer { _ = try? skipWhitespace() }
        
        switch peek() {
        case objectOpen:
            return try parseObject()
        case arrayOpen:
            return try parseArray()
        case quote:
            return try .string(parseString())
        case minus, numbers:
            return try parseNumber()
        case f:
            pop()
            try assertFollowedBy(alse)
            return .bool(false)
        case t:
            pop()
            try assertFollowedBy(rue)
            return .bool(true)
        case n:
            pop()
            try assertFollowedBy(ull)
            return .null
        default:
            throw Error.Reason.invalidSyntax
        }
    }
    
    func assertFollowedBy(_ chars: [UTF8.CodeUnit]) throws {
        try chars.forEach {
            guard $0 == pop() else { throw Error.Reason.invalidLiteral }
        }
    }
    
    func parseObject() throws -> JSON {
        assert(peek() == objectOpen)
        pop()
        
        try skipWhitespace()
        
        guard peek() != objectClose else {
            pop()
            return .object([:])
        }
        
        var tempDict: [String: JSON] = Dictionary.init(minimumCapacity: 6)
        var wasComma = false
        
        repeat {
            switch peek() {
            case comma:
                guard !wasComma else { throw Error.Reason.trailingComma }
                
                wasComma = true
                pop()
                try skipWhitespace()
            case quote:
                if tempDict.count > 0 && !wasComma {
                    throw Error.Reason.expectedComma
                }
                
                let key = try parseString()
                try skipWhitespace()
                
                guard pop() == colon else { throw Error.Reason.expectedColon }
                try skipWhitespace()
                
                let value = try parseValue()
                wasComma = false
                
                switch value {
                case nil where omitNulls:
                    break
                default:
                    tempDict[key] = value
                }
                
            case objectClose:
                guard !wasComma else { throw Error.Reason.trailingComma }
                
                pop()
                return .object(tempDict)
                
            default:
                throw Error.Reason.invalidSyntax
            }
        } while true
    }
    
    func parseArray() throws -> JSON {
        assert(peek() == arrayOpen)
        pop()
        
        try skipWhitespace()
        
        guard peek() != arrayClose else {
            pop()
            return .array([])
        }
        
        var tempArray: [JSON] = []
        tempArray.reserveCapacity(20)
        
        var wasComma = false
        
        repeat {
            switch peek() {
            case comma:
                guard !wasComma, !tempArray.isEmpty else {
                    throw Error.Reason.invalidSyntax
                }
                
                wasComma = true
                try skipComma()
            case arrayClose:
                guard !wasComma else { throw Error.Reason.invalidSyntax }
                
                _ = pop()
                return .array(tempArray)
            case nil:
                throw Error.Reason.endOfStream
            default:
                if !wasComma && !tempArray.isEmpty {
                    throw Error.Reason.expectedComma
                }
                
                let value = try parseValue()
                try skipWhitespace()
                wasComma = false
                
                switch value {
                case .null where omitNulls:
                    if peek() == comma {
                        try skipComma()
                        wasComma = true
                    }
                default:
                    tempArray.append(value)
                }
            }
        } while true
    }
    
    func parseNumber() throws -> JSON {
        assert(numbers ~= peek()! || minus == peek())
        
        var seenExponent = false // 有小数
        var seenDecimal = false  // 有指数
        
        let negative: Bool = {
            guard minus == peek() else { return false }
            pop()
            return true
        }()
        
        var significand: UInt64 = 0
        var mantisa: UInt64 = 0
        var divisor: Double = 1
        var exponent: UInt64 = 0
        var negativeExponent = false
        var didOverflow = false
        
        repeat {
            switch peek() {
            // 数字（没有小数，也没有小数点）
            case numbers where !seenDecimal && !seenExponent:
                // 将原本的数字向左挪一位
                // 0183 -> 1830
                (significand, didOverflow) = significand.multipliedReportingOverflow(by: 10)
                guard !didOverflow else { throw Error.Reason.numberOverflow }
                
                // 把新的数字放到个位上
                // 1830 + 7 -> 1837
                (significand, didOverflow) = significand.addingReportingOverflow(UInt64(pop() - zero))
                guard !didOverflow else { throw Error.Reason.numberOverflow }

            // 数字（有小数的）
            case numbers where seenDecimal && !seenExponent :
                // 用 divisor 表示小数点的位置
                divisor *= 10
                
                // 有了 divisor，就可以先用整数来表示当前的数字
                (mantisa, didOverflow) = mantisa.multipliedReportingOverflow(by: 10)
                guard !didOverflow else { throw Error.Reason.numberOverflow }
                
                (mantisa, didOverflow) = mantisa.addingReportingOverflow(UInt64(pop() - zero))
                guard !didOverflow else { throw Error.Reason.numberOverflow }
                
            // 数字（带指数的）
            case numbers where seenExponent:
                (exponent, didOverflow) = exponent.multipliedReportingOverflow(by: 10)
                guard !didOverflow else { throw Error.Reason.numberOverflow }
                
                (exponent, didOverflow) = exponent.addingReportingOverflow(UInt64(pop() - zero))
                guard !didOverflow else { throw Error.Reason.numberOverflow }
                
            // 小数点
            case decimal where !seenExponent && !seenDecimal:
                pop()
                seenDecimal = true
                guard let next = peek(), numbers ~= next else { throw Error.Reason.invalidNumber }
            
            // E 或者 e
            case E? where !seenExponent, e? where !seenExponent:
                pop()
                seenExponent = true

                if peek() == minus {
                    negativeExponent = true
                    pop()
                } else if peek() == plus {
                    pop()
                }
                
                guard let next = peek(), numbers ~= next else { throw Error.Reason.invalidNumber }
            
            // 终止符
            case let value? where value.isTerminator:
                fallthrough
                
            case nil:
                return try constructNumber(
                    significand     : significand,
                    mantisa         : seenDecimal  ? mantisa  : nil,
                    exponent        : seenExponent ? exponent : nil,
                    divisor         : divisor,
                    negative        : negative,
                    negativeExponent: negativeExponent)
                
            default:
                throw Error.Reason.invalidNumber
            }
        } while true
    }
    
    func constructNumber(significand: UInt64, mantisa: UInt64?, exponent: UInt64?, divisor: Double, negative: Bool, negativeExponent: Bool) throws -> JSON {
        // 没有尾数或者没有指数
        if mantisa != nil || exponent != nil {
            let number = Double(negative ? -1 : 1) * (Double(significand) + Double(mantisa ?? 0) / divisor)
            
            // 有指数的时候计算完再乘上去
            if let exponent = exponent {
                let doubleExponent = Double(exponent)
                return .double(Double(number) * pow(10, negativeExponent ? -doubleExponent : doubleExponent))
            } else {
                return .double(number)
            }
        } else {
            switch significand {
            // 正数
            case validUnsigned64BitInteger where !negative:
                return .integer(Int64(significand))
            // 负数且超出了 Int64 的范围
            case UInt64(Int64.max) + 1 where negative:
                return .integer(Int64.min)
            // 负数
            case validUnsigned64BitInteger where negative:
                return .integer(-Int64(significand))
            default:
                throw Error.Reason.numberOverflow
            }
        }
    }
    
    func parseString() throws -> String {
        assert(peek() == quote)
        pop()
        
        var isEscaped = false
        stringBuffer.removeAll(keepingCapacity: true)
        
        repeat {
            guard let codeUnit = peek() else { throw Error.Reason.invalidEscape }

            pop()
            
            // 字符为 \\ 且非转义，进入转义模式
            if codeUnit == backslash && !isEscaped {
                isEscaped = true
            // 字符为 " 且非转义
            } else if codeUnit == quote && !isEscaped {
                stringBuffer.append(0)
                return stringBuffer.withUnsafeBufferPointer { bufferPoint in
                    return String(cString: unsafeBitCast(bufferPoint.baseAddress, to: UnsafePointer<CChar>.self))
                }
            // 转义
            } else if isEscaped {
                switch codeUnit {
                case r         : stringBuffer.append(cr)
                case t         : stringBuffer.append(tab)
                case n         : stringBuffer.append(newline)
                case b         : stringBuffer.append(backspace)
                case f         : stringBuffer.append(formfeed)
                case quote     : stringBuffer.append(quote)
                case slash     : stringBuffer.append(slash)
                case backslash : stringBuffer.append(backslash)
                case u         : UTF8.encode(try parseUnicodeScalar(), into: { stringBuffer.append($0) })
                default        : throw Error.Reason.invalidUnicode
                }
                
                isEscaped = false
            // 排除掉非法的 Unicode 字符和非法的字符
            } else if invalidUnicodeBytes.contains(codeUnit) || codeUnit == 0xC0 || codeUnit == 0xC1 {
                throw Error.Reason.invalidUnicode
            } else {
                stringBuffer.append(codeUnit)
            }
        } while true
    }
}

private extension JSONParser {
    
    func parseUnicodeEscape() throws -> UTF16.CodeUnit {
        // 总共十六位，分成四次完成，每次编码四位
        // 0b 0000 0000 0000 0000
        return try (0..<4).reduce(0b0000000000000000) { (codeUnit, _) in
            var newCodeUnit = codeUnit << 4
            
            // 下面是一些 Magic Number，可以将 UTF8 转为 Unicode
            let code = pop()
            switch code {
            case numbers           : newCodeUnit += UInt16(code - 48)
            case alphaNumericLower : newCodeUnit += UInt16(code - 87)
            case alphaNumericUpper : newCodeUnit += UInt16(code - 55)
            default                : throw Error.Reason.invalidEscape
            }
            
            return newCodeUnit
        }
    }
    
    func parseUnicodeScalar() throws -> UnicodeScalar {
        var buffer: [UTF16.CodeUnit] = []
        
        // 构造 UTF 16 的第一个字节
        let codeUnit = try parseUnicodeEscape()
        buffer.append(codeUnit)
        
        // http://blog.csdn.net/shuilan0066/article/details/7865715
        // 查看 UTF16 是否有辅助位
        if UTF16.isLeadSurrogate(codeUnit) {
            // 将 UTF 16 的第二个字节也构造出来
            guard pop() == backslash && pop() == u else { throw Error.Reason.invalidUnicode }
            let trailingSurrogate = try parseUnicodeEscape()
            guard UTF16.isTrailSurrogate(trailingSurrogate) else { throw Error.Reason.invalidUnicode }
            buffer.append(trailingSurrogate)
        }
        
        var gen = buffer.makeIterator()
        
        var utf = UTF16()
        
        switch utf.decode(&gen) {
        case .scalarValue(let scalar) : return scalar
        case .emptyInput, .error      : throw Error.Reason.invalidUnicode
        }
    }
    
    func skipComma() throws {
        assert(peek() == comma)
        pop()
        try skipWhitespace()
    }
    
    func skipWhitespace() throws {
        func skipComments() throws -> Bool {
            if hasPrefix(lineComment) {
                while let char = peek(), char != newline {
                    pop()
                }
                
                return true
            } else if hasPrefix(blockCommentStart) {
                pop()           // '/'
                pop()           // '*'
                defer { pop() } // '/'
                
                // 处理多个注释嵌套的问题
                var depth: UInt = 1
                repeat {
                    guard let _ = peek() else {
                        throw Error.Reason.unmatchedComment
                    }
                    
                    if hasPrefix(blockCommentStart) {
                        depth += 1
                    } else if hasPrefix(blockCommentEnd) {
                        depth -= 1
                    }

                    pop()
                } while depth > 0
                
                return true
            }
            
            return false
        }
        
        while pointer != buffer.endAddress && pointer.pointee.isWhiteSpace {
            pop()
        }
    }
}

fileprivate extension UnsafeBufferPointer {
    
    var endAddress: UnsafePointer<Element> {
        return baseAddress!.advanced(by: endIndex)
    }
}

fileprivate extension UTF8.CodeUnit {
    
    var isWhiteSpace: Bool {
        return [space, tab, cr, newline, formfeed].contains(self)
    }
    
    var isTerminator: Bool {
        return [space, comma, objectClose, arrayClose].contains(self)
    }
}
