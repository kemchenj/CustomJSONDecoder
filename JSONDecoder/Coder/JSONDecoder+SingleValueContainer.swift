//
//  JSONDecoder+SingleValueContainer.swift
//  JSONCoder
//
//  Created by kemchenj on 31/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

import Foundation

extension _JSONDecoder: SingleValueDecodingContainer {

    func decodeNil() -> Bool {
        return unboxNil(currentContainer ?? container)
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        return try unbox(currentContainer ?? container)
    }
    
    func decode(_ type: String.Type) throws -> String {
        return try unbox(currentContainer ?? container)
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try unboxDecodable(currentContainer ?? container)
    }
}
