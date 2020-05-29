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
    func apply(image: CIImage) -> CIImage
}

class StruccLayerInstruction: AVVideoCompositionLayerInstruction, StruccLayerInstructionProtocol {
    enum LayerType { case background, foreground }

    public let layerType: LayerType
    let assetTrack: AVAssetTrack
    override var trackID: CMPersistentTrackID { return assetTrack.trackID }

    init(type: LayerType, assetTrack: AVAssetTrack) {
        self.layerType = type
        self.assetTrack = assetTrack
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(image: CIImage) -> CIImage {
        switch layerType {
        case .background:
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = image
            let filtered = filter.outputImage
            return filtered ?? image
        case .foreground: return image

        }
    }
}
