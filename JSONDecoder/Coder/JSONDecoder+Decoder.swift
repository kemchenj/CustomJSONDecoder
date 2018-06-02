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

    var object: JSONObject

    var currentObject: JSONObject!

    init(referencing object: JSONObject, at codingPath: [CodingKey] = []) {
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

    func container<Key>(keyedBy type: Key.Type, wrapping object: JSONObject) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard case let .object(unwrappedObject) = object else {
            throw DecodingError._typeMismatch(
                at: codingPath,
                expectation: [String: JSONObject].self,
                reality: object
            )
        }

        let keyedContainer = _KeyedContainer<Key>(referencing: self, wrapping: unwrappedObject)
        return KeyedDecodingContainer(keyedContainer)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try unkeyedContainer(wrapping: currentObject ?? object)
    }

    func unkeyedContainer(wrapping object: JSONObject) throws -> UnkeyedDecodingContainer {
        guard case let .array(array) = object else {
            throw DecodingError._typeMismatch(
                at: codingPath,
                expectation: [String: JSONObject].self,
                reality: object
            )
        }

        return _UnkeyedContainer(referencing: self, wrapping: array)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return _SingleValueDecodingContainer(referencing: self, wrapping: currentObject)
    }

    @inline(__always)
    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return _JSONDecoder(referencing: currentObject ?? object, at: codingPath)
    }

    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: JSONKey.super)
    }

    func superDecoder(forKey key: CodingKey) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

//
// MARK: - Unbox
//

extension _JSONDecoder {

    func unbox<T>(_ object: JSONObject, forKey key: CodingKey) throws -> T where T: BinaryFloatingPoint, T: LosslessStringConvertible {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox<T>(_ object: JSONObject) throws -> T where T: BinaryFloatingPoint, T: LosslessStringConvertible {
        switch object {
        case let .integer(number):
            guard let integer = T(exactly: number) else {
                throw DecodingError._numberMisfit(
                    at: codingPath,
                    expectation: T.self,
                    reality: number
                )
            }
            return integer
        case let .double(number):
            switch T.self {
            case is Double.Type:
                guard let double = Double.init(exactly: number) else {
                    throw DecodingError._numberMisfit(
                        at: codingPath,
                        expectation: T.self,
                        reality: number
                    )
                }
                return double as! T
            case is Float.Type:
                guard let float = Float(exactly: number) else {
                    throw DecodingError._numberMisfit(
                        at: codingPath,
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
            throw DecodingError._typeMismatch(
                at: codingPath,
                expectation: T.self,
                reality: object
            )
        }
    }

    func unbox<T>(_ object: JSONObject, forKey key: CodingKey) throws -> T where T: FixedWidthInteger {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox<T>(_ object: JSONObject) throws -> T where T: FixedWidthInteger {
        switch object {
        case let .integer(number):
            guard let integer = T(exactly: number) else {
                throw DecodingError._numberMisfit(
                    at: codingPath,
                    expectation: T.self,
                    reality: number
                )
            }
            return integer
        case let .double(number):
            guard let double = T(exactly: number) else {
                throw DecodingError._numberMisfit(
                    at: codingPath,
                    expectation: T.self,
                    reality: number
                )
            }
            return double
        case let .string(string):
            guard let number = T(string) else { fallthrough }
            return number
        default:
            throw DecodingError._typeMismatch(
                at: codingPath,
                expectation: T.self,
                reality: object
            )
        }
    }

    func unbox(_ object: JSONObject, forKey key: CodingKey) throws -> Bool {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox(_ object: JSONObject) throws -> Bool {
        func throwError() throws -> Never {
            throw DecodingError._typeMismatch(
                at: codingPath,
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

    func unbox(_ object: JSONObject, forKey key: CodingKey) throws -> String {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unbox(object)
    }

    func unbox(_ object: JSONObject) throws -> String {
        switch object {
        case .bool, .double, .integer, .string:
            return object.description
        case .array, .object, .null:
            throw DecodingError._typeMismatch(
                at: codingPath,
                expectation: String.self,
                reality: object
            )
        }
    }

    func unboxDecodable<T>(_ object: JSONObject, forKey key: CodingKey) throws -> T where T: Decodable {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try unboxDecodable(object)
    }

    func unboxDecodable<T>(_ object: JSONObject) throws -> T where T: Decodable {
        currentObject = object

        return try T.init(from: self)
    }

    func unboxNil(_ object: JSONObject, forKey key: CodingKey) -> Bool {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        return unboxNil(object)
    }

    func unboxNil(_ object: JSONObject) -> Bool {
        return object == .null
    }
}
