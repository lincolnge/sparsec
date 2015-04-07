//
//  combTests.swift
//  sparsec
//
//  Created by lincoln on 03/04/2015.
//  Copyright (c) 2015 Dwarf Artisan. All rights reserved.
//
// The testing name of last number is the serial number
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
            XCTAssert(false, "c is equal to data[0] but got error: \(msg)")
        }
    }
    
    func testEither1a() {
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
            XCTAssert(false, "data[0] is equal to c or to d but got error: \(msg)")
        }
    }
    
    func testEither2a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        var (re, status) = either(one(c), one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data[0] is equal to c but got error")
        case let .Failed(msg):
            XCTAssert(true)
        }
    }
    
    func testEither3a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "v"
        var (re, status) = either(try(one(c)), one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data is neither equal to c nor to d")
        case let .Failed(msg):
            XCTAssert(true)
        }
    }
    
    func testEither1b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        var (re, status) = (try(one(c)) <|> one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(true, "pass")
        case let .Failed(msg):
            XCTAssert(false, "data[0] is either equal to c or to d but got error: \(msg)")
        }
    }
    
    func testEither2b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "t"
        var (re, status) = (one(c) <|> one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data[0] is equal to c but error")
        case let .Failed(msg):
            XCTAssert(true)
        }
    }
    
    func testEither3b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "u"
        let d: UnicodeScalar = "v"
        var (re, status) = (try(one(c)) <|> one(d))(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data is neither equal to c nor to d")
        case let .Failed(msg):
            XCTAssert(true)
        }
    }
    
    func testOtherwise1a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        var (re, status) = otherwise(one(c), "data is not equal to c")(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(true)
        case let .Failed(msg):
            XCTAssert(false, msg)
        }
    }
    
    func testOtherwise2a() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        var (re, status) = otherwise(one(c), "data is not equal to c")(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false)
        case let .Failed(msg):
            XCTAssert(true, msg)
        }
    }
    
    func testOtherwise1b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "t"
        var (re, status) = (one(c) <?> "data is not equal to c")(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(true)
        case let .Failed(msg):
            XCTAssert(false, msg)
        }
    }
    
    func testOtherwise2b() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "b"
        var (re, status) = (one(c) <?> "data is not equal to c")(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false)
        case let .Failed(msg):
            XCTAssert(true, msg)
        }
    }
    
    func testOption() {
        let data = "t"
        let state = BasicState(data.unicodeScalars)
        let c: UnicodeScalar = "1"
        let d: UnicodeScalar = "d"

        var (re, status) = option(try(one(c)), d)(state)
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(re==d, "re is \(re) and equal to \(d)")
        case let .Failed(msg):
            XCTAssert(false, msg)
        }
    }
    
    func testOneOf1() {
        let data = "2"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        var (re, status) = oneOf(c.unicodeScalars)(state)
        
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(true)
        case let .Failed(msg):
            XCTAssert(false, msg)
        }
    }
    
    func testOneOf2() {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        var (re, status) = oneOf(c.unicodeScalars)(state)
        
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data is not in c")
        case let .Failed(msg):
            XCTAssert(true, msg)
        }
    }
    
    func testNoneOf1() {
        let data = "b"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        var (re, status) = noneOf(c.unicodeScalars)(state)
        
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(true)
        case let .Failed(msg):
            XCTAssert(false, msg)
        }
    }

    func testNoneOf2() {
        let data = "2"
        let state = BasicState(data.unicodeScalars)
        let c = "3fs2ad1"
        
        var (re, status) = noneOf(c.unicodeScalars)(state)
        
        println("(re, status): \((re, status))")
        switch status {
        case .Success:
            XCTAssert(false, "data is not in c")
        case let .Failed(msg):
            XCTAssert(true, msg)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
