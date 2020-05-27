//
//  CameraViewModelTests.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import strucc

class CameraViewModelTests: XCTestCase {
    var viewModel: CameraViewModelProtocol!
    var cameraRecorder: CameraRecorderMock!

    private var bindings = Set<AnyCancellable>()

    override func setUp() {
        cameraRecorder = CameraRecorderMock()
        viewModel = CameraViewModel(cameraRecorder)
    }

    func testRecord() {
        let expectation = XCTestExpectation(description: "Receive new value")
        viewModel.isButtonSelected
            .dropFirst()
            .sink { (value) in
            XCTAssertTrue(value)
            expectation.fulfill()
        }.store(in: &bindings)

        viewModel.recordButtonAction()

        wait(for: [expectation], timeout: 1)
    }

    func testRecordTwoTimes() {
        let expectationButtonState = XCTestExpectation(description: "Receive new value")

        viewModel.isButtonSelected
            .dropFirst(2)
            .sink { (value) in
                XCTAssertFalse(value)
                expectationButtonState.fulfill()
        }
        .store(in: &bindings)

        viewModel.recordButtonAction()
        viewModel.recordButtonAction()

        wait(for: [expectationButtonState], timeout: 1)
    }

    func testRoutePublisher() {

        let expectationRotueReceived = XCTestExpectation(description: "Route received")
        let urls: [URL] = [URL(string: "1"), URL(string: "2")].compactMap { $0 }

        viewModel
            .navigate
            .dropFirst()
            .sink { (route) in
                XCTAssertEqual(route, Routes.preview(urls: urls))
                expectationRotueReceived.fulfill()
        }
        .store(in: &bindings)

        viewModel.recordButtonAction()
        cameraRecorder.videosUrls.append(urls[0])
        viewModel.recordButtonAction()
        viewModel.recordButtonAction()
        cameraRecorder.videosUrls.append(urls[1])
        viewModel.recordButtonAction()

        wait(for: [expectationRotueReceived], timeout: 1)
    }
}
