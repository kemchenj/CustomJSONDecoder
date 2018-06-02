//
//  JSONDecoder+Internal.swift
//  JSONCoder
//
//  Created by kemchenj on 31/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

import Foundation

final class _JSONDecoder: Decoder {

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any]

    var object: JSON

    var currentObject: JSON!

    init(referencing object: JSON, at codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
        self.object = object
        self.userInfo = [:]
        self.currentObject = object
    }
}

//
// MARK: - Container
//

extension _JSONDecoder {

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return try container(keyedBy: type, wrapping: currentObject ?? object)
    }

    func container<Key>(keyedBy type: Key.Type, wrapping object: JSON) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard case let .object(unwrappedObject) = object else {
            throw _typeMismatch(
                expectation: [String: JSON].self,
                reality: object
            )
        }

        let keyedContainer = _KeyedContainer<Key>(referencing: self, wrapping: unwrappedObject)
        return KeyedDecodingContainer(keyedContainer)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try unkeyedContainer(wrapping: currentObject ?? object)
    }

    func unkeyedContainer(wrapping object: JSON) throws -> UnkeyedDecodingContainer {
        guard case let .array(array) = object else {
            throw _typeMismatch(
                expectation: [String: JSON].self,
                reality: object
            )
        }

        return _UnkeyedContainer(referencing: self, wrapping: array)
    }
}

//
// MARK: - Unbox
//

extension _JSONDecoder {

    func unbox<T>(_ object: JSON, forKey key: CodingKey) throws -> T where T: BinaryFloatingPoint, T: LosslessStringConvertible {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox<T>(_ object: JSON) throws -> T where T: BinaryFloatingPoint, T: LosslessStringConvertible {
        switch object {
        case let .integer(number):
            guard let integer = T(exactly: number) else {
                throw _numberMisfit(
                    expectation: T.self,
                    reality: number
                )
            }
            return integer
        case let .double(number):
            switch T.self {
            case is Double.Type:
                guard let double = Double.init(exactly: number) else {
                    throw _numberMisfit(
                        expectation: T.self,
                        reality: number
                    )
                }
                return double as! T
            case is Float.Type:
                guard let float = Float(exactly: number) else {
                    throw _numberMisfit(
                        expectation: T.self,
                        reality: number
                    )
                }
                return float as! T
            default:
                fatalError()
            }
        case let .bool(bool):
            return bool ? 1 : 0
        case let .string(string):
            guard let number = T(string) else { fallthrough }
            return number
        default:
            throw _typeMismatch(
                expectation: T.self,
                reality: object
            )
        }
    }

    func unbox<T>(_ object: JSON, forKey key: CodingKey) throws -> T where T: FixedWidthInteger {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox<T>(_ object: JSON) throws -> T where T: FixedWidthInteger {
        switch object {
        case let .integer(number):
            guard let integer = T(exactly: number) else {
                throw _numberMisfit(
                    expectation: T.self,
                    reality: number
                )
            }
            return integer
        case let .double(number):
            guard let double = T(exactly: number) else {
                throw _numberMisfit(
                    expectation: T.self,
                    reality: number
                )
            }
            return double
        case let .string(string):
            guard let number = T(string) else { fallthrough }
            return number
        default:
            throw _typeMismatch(
                expectation: T.self,
                reality: object
            )
        }
    }

    func unbox(_ object: JSON, forKey key: CodingKey) throws -> Bool {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox(_ object: JSON) throws -> Bool {
        func throwError() throws -> Never {
            throw _typeMismatch(
                expectation: Bool.self,
                reality: object
            )
        }

        switch object {
        case let .bool(bool):
            return bool
        case let .integer(integer):
            switch integer {
            case 0  : return true
            case 1  : return false
            default : try throwError()
            }
        case let .double(double):
            switch double {
            case 0  : return true
            case 1  : return false
            default : try throwError()
            }
        case let .string(string):
            guard let bool = Bool(string) else { try throwError() }
            return bool
        case .array, .object, .null:
            try throwError()
        }
    }

    func unbox(_ object: JSON, forKey key: CodingKey) throws -> String {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox(_ object: JSON) throws -> String {
        switch object {
        case .bool, .double, .integer, .string:
            return object.description
        case .array, .object, .null:
            throw _typeMismatch(
                expectation: String.self,
                reality: object
            )
        }
    }

    func unboxDecodable<T>(_ object: JSON, forKey key: CodingKey) throws -> T where T: Decodable {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unboxDecodable(object)
    }

    func unboxDecodable<T>(_ object: JSON) throws -> T where T: Decodable {
        currentObject = object

        return try T.init(from: self)
    }

    func unboxNil(_ object: JSON, forKey key: CodingKey) -> Bool {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return unboxNil(object)
    }

    func unboxNil(_ object: JSON) -> Bool {
        return object == .null
    }
}

//
// MARK: - Error Handling
//

extension _JSONDecoder {

    private func _typeMismatch(expectation: Any.Type, reality: JSON) -> DecodingError {
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Expected to decode \(expectation) but found \(reality)) instead."
        )
        return DecodingError.typeMismatch(expectation, context)
    }

    private func _numberMisfit(expectation: Any.Type, reality: CustomStringConvertible) -> DecodingError {
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Parsed JSON number <\(reality)> does not fit in \(expectation)."
        )
        return DecodingError.dataCorrupted(context)
    }
}
