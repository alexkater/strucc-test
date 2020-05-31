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
                XCTAssertEqual(route, Route.preview(urls: urls))
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

    func testViewAppear() {
        viewModel.viewAppear()
        XCTAssertEqual(cameraRecorder.startSessionCalls, 1)
    }

    func testViewDisappear() {
        viewModel.viewDisappear()
        XCTAssertEqual(cameraRecorder.stopSessionCalls, 1)
    }

    func testSwitchCamera() {
        viewModel.switchCamera()
        XCTAssertEqual(cameraRecorder.switchCameraCalls, 1)
    }

    func testRecordThrowError() {
        let expectation = XCTestExpectation(description: "Error received")

        let error: CameraError = CameraError.cameraBuild
        viewModel
            .error
            .dropFirst()
            .sink { (errorString) in
                XCTAssertEqual(errorString, error.localizedDescription)
                expectation.fulfill()
        }
        .store(in: &bindings)

        cameraRecorder.recordError = error
        viewModel.recordButtonAction()

        wait(for: [expectation], timeout: 1)
    }

    func testSwitchCameraThrowError() {
        let expectation = XCTestExpectation(description: "Error received")

        let error: CameraError = CameraError.cameraBuild
        viewModel
            .error
            .dropFirst()
            .sink { (errorString) in
                XCTAssertEqual(errorString, error.localizedDescription)
                expectation.fulfill()
        }
        .store(in: &bindings)

        cameraRecorder.switchCameraError = error
        viewModel.switchCamera()

        wait(for: [expectation], timeout: 1)
    }

    func testHelperTexts() {
        let expectationRotueReceived = XCTestExpectation(description: "Helper texts")
        let urls: [URL] = [URL(string: "1"), URL(string: "2")].compactMap { $0 }

        viewModel
            .helperText
            .collect(4)
            .sink { (texts) in

                XCTAssertNil(texts[0])
                XCTAssertEqual(texts[1], "Record 2 videos!")
                XCTAssertEqual(texts[2], "Record another one :)")
                XCTAssertEqual(texts[3], "Editing time!")
                expectationRotueReceived.fulfill()
        }
        .store(in: &bindings)

        viewModel.viewAppear()
        viewModel.recordButtonAction()
        cameraRecorder.videosUrls.append(urls[0])
        viewModel.recordButtonAction()
        viewModel.recordButtonAction()
        cameraRecorder.videosUrls.append(urls[1])
        viewModel.recordButtonAction()

        wait(for: [expectationRotueReceived], timeout: 1)
    }
}
