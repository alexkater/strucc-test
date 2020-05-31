//
//  FontTest.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 31/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import XCTest

@testable import strucc

class FontTest: XCTestCase {

    func testPostGrotestBold() {
        XCTAssertNotNil(UIFont.postGrotestBold(14))
    }
}
