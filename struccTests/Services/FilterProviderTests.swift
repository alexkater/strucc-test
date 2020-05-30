//
//  FilterProviderTests.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 30/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import XCTest

@testable import strucc

class FilterProviderTests: XCTestCase {

    var filterProvider: FilterProviderProtocol!

    override func setUp() {
        filterProvider = FilterProvider()
    }

    func testFilters() {
        XCTAssertEqual(filterProvider.filters.count, 4)

        var filter = filterProvider.filters[0]
        XCTAssertEqual(filter.name, "No Filter")
        XCTAssertEqual(filter.imageName, "ThumbNoFilter")
        XCTAssertNil(filter.filter)

        filter = filterProvider.filters[1]
        XCTAssertEqual(filter.name, "Chrome")
        XCTAssertEqual(filter.imageName, "ThumbChrome")
        XCTAssertNotNil(filter.filter)

        filter = filterProvider.filters[2]
        XCTAssertEqual(filter.name, "Instant")
        XCTAssertEqual(filter.imageName, "ThumbInstant")
        XCTAssertNotNil(filter.filter)

        filter = filterProvider.filters[3]
        XCTAssertEqual(filter.name, "Noir")
        XCTAssertEqual(filter.imageName, "ThumbNoir")
        XCTAssertNotNil(filter.filter)
    }

    func testPreselectedFilter() {
        XCTAssertEqual(filterProvider.selectedFilter, filterProvider.filters[0])
    }
}
