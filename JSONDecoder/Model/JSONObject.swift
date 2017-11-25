//
//  JSONObject.swift
//  JSONCoder
//
//  Created by kemchenj on 20/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

public enum JSONObject {
    
    indirect case array([JSONObject])
    indirect case object([String: JSONObject])
    case null
    case bool(Bool)
    case string(String)
    case double(Double)
    case integer(Int64)
}

extension JSONObject: Equatable {
    
    public static func ==(lhs: JSONObject, rhs: JSONObject) -> Bool {
        switch (lhs, rhs) {
        case let (.array(l)  , .array(r))   : return l == r
        case let (.object(l) , .object(r))  : return l == r
        case     (.null      , .null)       : return true
        case let (.bool(l)   , .bool(r))    : return l == r
        case let (.string(l) , .string(r))  : return l == r
        case let (.double(l) , .double(r))  : return l == r
        case let (.integer(l), .integer(r)) : return l == r
        default                             : return false
        }
    }
}

extension JSONObject: Sequence {
    
    public func makeIterator() -> AnyIterator<JSONObject> {
        switch self {
        case let .array(array):
            var iterator = array.makeIterator()
            return AnyIterator {
                return iterator.next()
            }
        case let .object(object):
            var iterator = object.makeIterator()
            return AnyIterator {
                guard let (key, value) = iterator.next() else {
                    return nil
                }
                return .object([key: value])
            }
        default:
            var value: JSONObject? = self
            
            return AnyIterator {
                defer { value = nil }
                if case .null? = value { return nil }
                return value
            }
        }
    }
}

extension JSONObject: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .array(array)      : return array.description
        case let .object(object)    : return object.description
        case let .bool(bool)        : return bool.description
        case let .string(string)    : return string.description
        case let .double(double)    : return double.description
        case let .integer(integer)  : return integer.description
        case .null                  : return "<null>"
        }
    }
}
