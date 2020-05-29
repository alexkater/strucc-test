//
//  PreviewViewModelTests.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import XCTest
import Combine

@testable import strucc

class CameraViewModelTests: XCTestCase {
    var viewModel: PreviewViewModelProtocol!
    var filterProvider: FilterProviderProtocol
    private var bindings = Set<AnyCancellable>()

    override func setUp() {
        viewModel = PreviewViewModel(
    }

    func testRecord() {

    }

}
