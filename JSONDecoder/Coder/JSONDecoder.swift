//
//  JSONDecoder.swift
//  JSONCoder
//
//  Created by kemchenj on 26/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

import struct Foundation.Data

public final class CustomDecoder {

    public static func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        
        let rootObject: JSON

        do {
            rootObject = try JSONParser.parse(data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "The given data was not valid JSON",
                underlyingError: error
            ))
        }

        let decoder = _JSONDecoder(referencing: rootObject)
        return try decoder.unboxDecodable(rootObject)
    }
}
