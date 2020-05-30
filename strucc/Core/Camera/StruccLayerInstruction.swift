//
//  StruccLayerInstruction.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 27/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage

protocol StruccLayerInstructionProtocol {
    func apply(image: CIImage, composedImage: CIImage, contextExtent: CGRect) -> CIImage?
}

class StruccLayerInstruction: AVVideoCompositionLayerInstruction, StruccLayerInstructionProtocol {
    enum LayerType { case backgroundFiltered, foregroundCropped }

    public let layerType: LayerType
    let assetTrack: AVAssetTrack
    override var trackID: CMPersistentTrackID { return assetTrack.trackID }

    private let filterProvider: FilterProviderProtocol

    init(type: LayerType, assetTrack: AVAssetTrack, filterProvider: FilterProviderProtocol? = nil) {
        self.layerType = type
        self.assetTrack = assetTrack
        self.filterProvider = filterProvider ?? FilterProvider.shared
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(image: CIImage, composedImage: CIImage, contextExtent: CGRect) -> CIImage? {
        switch layerType {
        case .backgroundFiltered:
            guard let filter = filterProvider.selectedFilter?.filter else { return image }

            return filter(image)?.composited(over: composedImage)
        case .foregroundCropped:

            let scaleFactor: CGFloat = 0.54
            let translateX = contextExtent.width * scaleFactor * (0.8)
            let translateY = contextExtent.height * scaleFactor * (0.8)

            let transform =
                CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                    .translatedBy(x: translateX, y: translateY)

            let cropped = image.transformed(by: transform)

            let filter = CIFilter.colorMatrix()
            let overlayRgba: [CGFloat] = [0, 0, 0, 0.7]
            let vector = CIVector(values: overlayRgba, count: 4)
            filter.aVector = vector
            filter.inputImage = cropped
            let filtered = filter.outputImage
            return filtered?.composited(over: composedImage)
        }
    }
}
