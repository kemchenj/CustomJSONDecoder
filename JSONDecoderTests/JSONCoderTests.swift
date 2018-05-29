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

    func largeData() -> Data {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        let url = URL(string: "file://\(parent)/large.json")!
        print("Loading fixture from url \(url)")

        return try! Data(contentsOf: url)
    }

    func testData() -> Data {
        return """
        {
          "super" : {
            "_id": "56c658d3e425523f3a636e64",
            "index": 0,
            "guid": "5a651472-d37b-4ad7-a556-9de70aa0dc28",
            "isActive": true,
            "balance": "$2,906.67",
            "picture": "http://placehold.it/32x32",
            "age": 37,
            "name": "Park Odom",
            "company": "SENSATE",
            "email": "parkodom@sensate.com",
            "phone": "+1 (954) 436-2958",
            "address": "406 Forest Place, Brownlee, American Samoa, 3358",
            "about": "Nisi enim amet proident ut labore voluptate cillum ea exercitation mollit reprehenderit occaecat labore. Nulla excepteur consectetur qui magna. Minim esse labore consequat sit dolore minim. Dolor eiusmod non laboris sit magna eu. Qui deserunt Lorem pariatur magna deserunt ad sit nostrud eu occaecat.",
            "registered": "2014-05-16T11:36:46 -01:00",
            "latitude": -25.472313,
            "longitude": 122.375678,
            "tags": [
              "nisi",
              "minim",
              "dolor",
              "in",
              "nisi",
              "esse",
              "magna"
            ],
            "greeting": "Hello, Park Odom! You have 2 unread messages.",
            "favoriteFruit": "banana"
          },
          "_id": "56c658d3e425523f3a636e64",
          "index": 0,
          "guid": "5a651472-d37b-4ad7-a556-9de70aa0dc28",
          "isActive": true,
          "balance": "$2,906.67",
          "picture": "http://placehold.it/32x32",
          "age": 37,
          "name": "Park Odom",
          "company": "SENSATE",
          "email": "parkodom@sensate.com",
          "phone": "+1 (954) 436-2958",
          "address": "406 Forest Place, Brownlee, American Samoa, 3358",
          "about": "Nisi enim amet proident ut labore voluptate cillum ea exercitation mollit reprehenderit occaecat labore. Nulla excepteur consectetur qui magna. Minim esse labore consequat sit dolore minim. Dolor eiusmod non laboris sit magna eu. Qui deserunt Lorem pariatur magna deserunt ad sit nostrud eu occaecat.",
          "registered": "2014-05-16T11:36:46 -01:00",
          "latitude": -25.472313,
          "longitude": 122.375678,
          "tags": [
            "nisi",
            "minim",
            "dolor",
            "in",
            "nisi",
            "esse",
            "magna"
          ],
          "greeting": "Hello, Park Odom! You have 2 unread messages.",
          "favoriteFruit": "banana",
          "eyeColor": "blue",
          "gender": "male",
          "friends": [
            {
              "id": 0,
              "name": "Ortiz Garrison"
            }
          ]
        }
        """.data(using: .utf8)!
    }

    func testCustomDecoder() {
        let data = testData()

        do {
            let _ = try! JSONSerialization.jsonObject(with: data, options: [])
            let originDecoderResult = try! JSONDecoder().decode(User.self, from: data)
            let customDecoderResult = try CustomDecoder.decode(User.self, from: data)

            XCTAssertEqual(customDecoderResult, originDecoderResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPerformanceCustomDecoder() {
        let data = largeData()

        measure {
            _ = try! CustomDecoder.decode([User].self, from: data)
        }
    }

    func testPerformanceOriginalDecoder() {
        let data = largeData()

        measure {
            _ = try! JSONDecoder().decode([TUser].self, from: data)
        }
    }

}
