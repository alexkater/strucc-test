//
//  VideoEditorTests.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 31/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import XCTest
import AVFoundation
import Combine

@testable import strucc

class VideoEditorTests: XCTestCase {
    var videoEditor: VideoEditorProtocol!
    private var bindings = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        videoEditor = VideoEditor()
    }

    func testCreateCompositionWork() {
        let expectation = XCTestExpectation(description: "Composition expectation")

        videoEditor
            .createComposition(urls: TestVideoMock.defaultUrls)
            .sink(receiveCompletion: { (completion) in
                print(completion)
            }) { (value) in

                let composition = value.0
                let videoComposition = value.1

                XCTAssertEqual(composition.duration.seconds.rounded(), 5)
                XCTAssertEqual(composition.tracks.count, 4)
                // TODO: @aarjonilla Check this size
                XCTAssertEqual(composition.naturalSize, CGSize(width: 1920, height: 1080))

                XCTAssertNotNil(videoComposition)
                XCTAssertEqual(videoComposition?.instructions.count, 1)
                XCTAssertEqual(videoComposition?.frameDuration, CMTime(value: 1, timescale: 60))

                expectation.fulfill()
        }.store(in: &bindings)

        wait(for: [expectation], timeout: 1)
    }

    func testCreateCompositionFaile() {
        let expectation = XCTestExpectation(description: "Composition expectation")

          videoEditor
              .createComposition(urls: [URL(string: "FakeUrl1")!, URL(string: "FakeUrl1")!])
              .sink(receiveCompletion: { (completion) in
                  print(completion)
                guard case .failure(let error) = completion else {
                    assertionFailure()
                    return
                }

                XCTAssertEqual(error, StruccError.cantTakeAVAssetTracks)
                  expectation.fulfill()
              }) { (_) in

          }.store(in: &bindings)

          wait(for: [expectation], timeout: 1)
    }
}
