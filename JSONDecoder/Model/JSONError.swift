//
//  JSONObjectError.swift
//  JSONCoder
//
//  Created by kemchenj on 24/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

extension JSON {
    
    enum Error: Swift.Error {
        case badFiled(String)
        case badValue(JSON)
        case invalidNumber
    }
}
