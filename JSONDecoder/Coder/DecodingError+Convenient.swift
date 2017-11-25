//
//  DecodingError+Convenient.swift
//  JSONCoder
//
//  Created by kemchenj on 05/11/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

extension DecodingError {

    static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: JSONObject) -> DecodingError {
        return DecodingError.typeMismatch(expectation, DecodingError.Context(codingPath: path, debugDescription: "Expected to decode \(expectation) but found \(reality)) instead."))
    }

    static func _numberMisfit(at path: [CodingKey], expectation: Any.Type, reality: CustomStringConvertible) -> DecodingError {
        return DecodingError.dataCorrupted(DecodingError.Context(codingPath: path, debugDescription: "Parsed JSON number <\(reality)> does not fit in \(expectation)."))
    }
}
