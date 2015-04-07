//
//  combTests.swift
//  sparsec
//
//  Created by lincoln on 03/04/2015.
//  Copyright (c) 2015 Dwarf Artisan. All rights reserved.
//

import Cocoa
import XCTest

class combTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTry() {
        let data = "t1"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        var (re, status) = try(one(c))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(msg):
            XCTAssert(false, "c is equal to data[0]")
        }
    }
    
    func testEither1() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        var (re, status) = either(try(one(c)), one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(msg):
            XCTAssert(false, "data[0] is equal to c or to d")
        }
    }
    
    func testEither2() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        var (re, status) = either(one(c), one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data[0] is equal to c")
        case let .Failed(msg):
            XCTAssert(true)
        }
    }
    
    func testEither3() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "v"
        var (re, status) = either(try(one(c)), one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data is not equal to c or to d")
        case let .Failed(msg):
            XCTAssert(true)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
