//
//  JSONDecoder+KeyedContainer.swift
//  JSONCoder
//
//  Created by kemchenj on 31/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

final class _KeyedContainer<K: CodingKey>: KeyedDecodingContainerProtocol {

    typealias Key = K
    
    private unowned let decoder: _JSONDecoder
    
    private let object: [String: JSONObject]
    
    var codingPath: [CodingKey] {
        get { return decoder.codingPath }
        set { decoder.codingPath = newValue }
    }
    
    init(referencing decoder: _JSONDecoder, wrapping object: [String: JSONObject]) {
        self.decoder  = decoder
        self.object  = object
    }
    
    var allKeys: [Key] {
        return object.keys.compactMap(Key.init)
    }
    
    func contains(_ key: Key) -> Bool {
        return object[key.stringValue] != nil
    }

    @inline(__always)
    private func getObject(forKey key: Key) throws -> JSONObject {
        guard let object = object[key.stringValue] else {
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."
            )
            throw DecodingError.keyNotFound(key, context)
        }

        return object
    }
}

extension _KeyedContainer {

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try decoder.unbox(getObject(forKey: key), forKey: key)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return try decoder.unboxNil(getObject(forKey: key), forKey: key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        return try decoder.unboxDecodable(getObject(forKey: key), forKey: key)
    }
}

//
// MARK: - [Decoding] Container
//

extension _KeyedContainer {

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        codingPath.append(key)
        defer { codingPath.removeLast() }

        let value = (key is JSONKey) == true
            ? JSONObject.object(object)
            : object[key.stringValue, default: .null]
        return _JSONDecoder(referencing: value, at: decoder.codingPath)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let object = try getObject(forKey: key)

        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try decoder.container(keyedBy: type, wrapping: object)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        let object = try getObject(forKey: key)

        codingPath.append(key)
        defer { codingPath.removeLast() }

        return try decoder.unkeyedContainer(wrapping: object)
    }

    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: JSONKey.super)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}
