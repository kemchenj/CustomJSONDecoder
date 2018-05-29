//
//  JSONDecoder+UnkeydContainer.swift
//  JSONCoder
//
//  Created by kemchenj on 31/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

import Foundation

struct _UnkeyedContainer: UnkeyedDecodingContainer {

    var codingPath: [CodingKey] {
        get { return decoder.codingPath }
        set { decoder.codingPath = newValue }
    }

    var count: Int? {
        return container.count
    }
    
    var isAtEnd: Bool {
        return container.count == currentIndex + 1
    }
    
    var currentIndex: Int

    private unowned let decoder: _JSONDecoder
    private let container: [JSONObject]

    init(referencing decoder: _JSONDecoder, wrapping container: [JSONObject]) {
        self.container = container
        self.decoder = decoder
        self.currentIndex = 0
    }

    private var currentKey: CodingKey {
        return JSONKey(index: currentIndex)
    }

    @inline(__always)
    private mutating func getCurrentObject() throws -> JSONObject {
        guard !isAtEnd else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath + [currentKey],
                debugDescription: "Unkeyed container is at end."
            )
            throw DecodingError.valueNotFound(JSONObject.self, context)
        }

        defer { currentIndex += 1 }

        return container[currentIndex]
    }

    mutating func decodeNil() throws -> Bool {
        return try decoder.unboxNil(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return try decoder.unbox(getCurrentObject(), forKey: currentKey)
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try decoder.unboxDecodable(getCurrentObject(), forKey: currentKey)
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return try decoder.container(keyedBy: type, wrapping: getCurrentObject())
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try decoder.unkeyedContainer(wrapping: getCurrentObject())
    }

    mutating func superDecoder() throws -> Decoder {
        return try _JSONDecoder(referencing: getCurrentObject(), at: decoder.codingPath)
    }

}
