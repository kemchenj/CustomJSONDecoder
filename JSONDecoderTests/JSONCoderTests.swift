//
//  JSONCoderTests.swift
//  JSONCoderTests
//
//  Created by kemchenj on 20/10/2017.
//  Copyright © 2017 kemchenj. All rights reserved.
//

import XCTest
import Foundation
import JSONDecoder

class JSONCoderTests: XCTestCase {

    func getData() -> Data {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        let url = URL(string: "file://\(parent)/large.json")!
        print("Loading fixture from url \(url)")

        return try! Data(contentsOf: url)
    }
    
    func testPerformanceCustomDecoder() {
        let data = getData()

        measure {
            _ = try! CustomDecoder.decode([User].self, from: data)
        }
    }

    func testPerformanceOriginalDecoder() {
        let data = getData()

        measure {
            _ = try! JSONDecoder().decode([User].self, from: data)
        }
    }

}
