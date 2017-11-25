//
//  JSONObject+Literal.swift
//  JSONCoder
//
//  Created by kemchenj on 12/11/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

extension JSONObject: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSONObject: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSONObject: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSONObject: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONObject...) {
        self = .array(elements)
    }
}

extension JSONObject: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension JSONObject: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONObject)...) {
        self = .object(Dictionary(elements, uniquingKeysWith: { $1}))
    }
}

extension JSONObject: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self = .integer(value)
    }
}
