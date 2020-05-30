//
//  PreviewViewModelTests.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import XCTest
import Combine
import AVFoundation

@testable import strucc

class PreviewViewModelTests: XCTestCase {
    var viewModel: PreviewViewModelProtocol!
    var filterProvider: FilterProviderMock!
    var videoEditor: VideoEditorMock!

    private var bindings = Set<AnyCancellable>()

    override func setUp() {
        filterProvider = FilterProviderMock()
        videoEditor = VideoEditorMock()

        setupViewModel()
    }

    func setupViewModel(_ compositionResult: Result<Composition, StruccError> = .success((AVComposition(), nil))) {

        videoEditor.futureMock = CompositionFuture { $0(compositionResult) }

        viewModel = PreviewViewModel(urls: [],
                                     filterProvider: filterProvider,
                                     videoEditor: videoEditor)
    }

    func testFiltersUpdate() {
        let expectation = XCTestExpectation(description: "Receive new value")

          viewModel.filters
              .sink { (value) in
                XCTAssertEqual(value.count, 2)
                let filter = value.first
                XCTAssertNotNil(filter)
                XCTAssertEqual(filter?.imageName, "Test")
                XCTAssertEqual(filter?.title, "Test")
                expectation.fulfill()
          }
          .store(in: &bindings)

          wait(for: [expectation], timeout: 1)
    }

    func testComposition() {
        let expectation = XCTestExpectation(description: "Receive new value")

          viewModel.composition
              .sink { (value) in
                XCTAssertNotNil(value)
                expectation.fulfill()
          }
          .store(in: &bindings)

          wait(for: [expectation], timeout: 1)
    }

    func testCompositionError() {
        let expectation = XCTestExpectation(description: "Receive new value")
        setupViewModel(.failure(.cantTakeTracks))

        viewModel.error
            .sink { (value) in
                XCTAssertNotNil(value)
                expectation.fulfill()
        }
        .store(in: &bindings)

        wait(for: [expectation], timeout: 1)
    }

    func testSelectionFilter() {
        viewModel.selectionCallbak(1)
        XCTAssertEqual(filterProvider.selectedFilter?.name, "Test2")
        XCTAssertEqual(filterProvider.selectedFilter?.imageName, "Test2")
    }
}
