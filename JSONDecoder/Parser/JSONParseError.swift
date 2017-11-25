//
//  JSONParseError.swift
//  JSONCoder
//
//  Created by kemchenj on 23/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

extension JSONParser {
    
    struct Error: Swift.Error, Equatable {
        public var byteOffset: Int
        public var reason: Reason
        
        public enum Reason: Swift.Error {
            case endOfStream
            case emptyStream
            case trailingComma
            case expectedComma
            case expectedColon
            case invalidEscape
            case invalidSyntax
            case invalidNumber
            case numberOverflow
            case invalidLiteral
            case invalidUnicode
            case fragmentedJSON
            case unmatchedComment
        }
        
        public static func ==(lhs: JSONParser.Error, rhs: JSONParser.Error) -> Bool {
            return lhs.reason == rhs.reason
                && lhs.byteOffset == rhs.byteOffset
        }
    }
}
