//
//  defineTests.swift
//  sparsec
//
//  Created by lincoln on 03/04/2015.
//  Copyright (c) 2015 Dwarf Artisan. All rights reserved.
//

import Cocoa
import XCTest

class defineTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEquals1() {
        // This is an example of a functional test case.
        let data1 = "equal1"
        let data2 = "equal1"
        let equal = equals(data1)
        let status = equal(data2)

        XCTAssert(status==true, "data1 is not equal to data2")
    }
    
    func testEquals2() {
        // This is an example of a functional test case.
        let data1 = "equal1"
        let data2 = "equal2"
        let status = equals(data1)(data2)
        
        XCTAssert(status==false, "data1 is equal to data2")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
