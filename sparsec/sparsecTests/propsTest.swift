//
//  propsTest.swift
//  sparsec
//
//  Created by Mars Liu on 15/3/27.
//  Copyright (c) 2015年 Dwarf Artisan. All rights reserved.
//

import Cocoa
import XCTest

class propsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFloat() {
        // This is an example of a functional test case.
        let data = "3.15926"
        let state = BasicState(data.unicodeScalars)
        let float = many(digit) >>= {(n:[UChr?]?)->Parsec<String, UStr>.Parser in
            return {(state:BasicState<UStr>)->(String?, ParsecStatus) in
                var (re, status) = (char(".") >> many1(digit))(state)
                switch status {
                case .Success:
                    return ("\(cs2str(n!)).\(cs2str(re!))", ParsecStatus.Success)
                case .Failed:
                    return (nil, status)
                }
            }
        }
        var (re, status) = float(state)
        switch status {
        case let .Failed(msg):
            XCTAssert(false, "excpet digit parsec got a digit but error: \(msg)")
        case .Success:
            println("float test success and got:\(re)")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
