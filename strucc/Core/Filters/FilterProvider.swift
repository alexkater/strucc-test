//
//  FilterProvider.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 28/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

typealias FilterFunc = (CIImage) -> CIImage?

struct Filter {

    let name: String
    let imageName: String
    let filter: FilterFunc?
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
