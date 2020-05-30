//
//  FilterProviderMock.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
@testable import strucc

final class FilterProviderMock: FilterProviderProtocol {

    var filters: [Filter] = [
        Filter(name: "Test", imageName: "Test", filter: nil),
        Filter(name: "Test2", imageName: "Test2", filter: nil)
    ]

    var selectedFilter: Filter?
}
