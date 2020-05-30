//
//  RouteTests.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 30/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import XCTest

@testable import strucc

class RouteTests: XCTestCase {

    func testCameraRoute() {
        XCTAssertTrue(Route.camera.controller is CameraViewController)
    }

    func testPreviewRoute() {
        XCTAssertTrue(Route.preview(urls: []).controller is PreviewViewController)
    }
}
