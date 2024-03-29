//
//  FilterProvider.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 28/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import CoreImage.CIFilterBuiltins

struct Filter: Equatable {

    let name: String
    let imageName: String
    let filter: FilterFunc?

    static func == (lhs: Filter, rhs: Filter) -> Bool {
        return lhs.name == rhs.name && lhs.imageName == rhs.imageName
    }
}

protocol FilterProviderProtocol {

    var filters: [Filter] { get }
    var selectedFilter: Filter? { get set }
}

final class FilterProvider: FilterProviderProtocol {

    static var shared: FilterProviderProtocol = FilterProvider()

    lazy var selectedFilter: Filter? = filters.first

    var filters: [Filter] {
        return [
            Filter(name: "No Filter", imageName: "ThumbNoFilter", filter: nil),
            Filter(name: "Chrome", imageName: "ThumbChrome", filter: Chrome()),
            Filter(name: "Instant", imageName: "ThumbInstant", filter: Instant()),
            Filter(name: "Noir", imageName: "ThumbNoir", filter: Noir())
        ]
    }
}

func Chrome() -> FilterFunc {
    return { image in
        let filter = CIFilter.photoEffectChrome()
        filter.inputImage = image
        return filter.outputImage
    }
}

func Instant() -> FilterFunc {
    return { image in
        let filter = CIFilter.photoEffectInstant()
        filter.inputImage = image
        return filter.outputImage
    }
}

func Noir() -> FilterFunc {
    return { image in
        let filter = CIFilter.photoEffectNoir()
        filter.inputImage = image
        return filter.outputImage
    }
}
