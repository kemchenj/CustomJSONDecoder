//
//  JSONKey.swift
//  JSONCoder
//
//  Created by kemchenj on 05/11/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

struct JSONKey : CodingKey {

    public var stringValue: String
    public var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    static let `super` = JSONKey(stringValue: "super")!
}
