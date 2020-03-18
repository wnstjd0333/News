//
//  NewsServiceTests.swift
//  NewsTests
//
//  Created by P1506 on 2020/02/18.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import XCTest
@testable import News

class NewsServiceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testfetchInternationalNews() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let service = NewsService()
        service.fetchInternationalNews(countryCode: "kr") { (success, articles) in
            XCTAssertEqual(success, true)
        }
        
        service.fetchInternationalNews(countryCode: "kr",page: 1) { (success, articles) in
            XCTAssertEqual(success, true)
        }
        
        service.fetchInternationalNews(countryCode: "kr",page: 2) { (success, articles) in
            XCTAssertEqual(success, true)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
