//
//  VideoCompositorInstruction.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 30/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import AVFoundation

final class VideoCompositionInstruction: NSObject, AVVideoCompositionInstructionProtocol {

    var timeRange: CMTimeRange = .zero
    var enablePostProcessing: Bool = false
    var containsTweening: Bool = false
    var requiredSourceTrackIDs: [NSValue]?
    var passthroughTrackID: CMPersistentTrackID = 0

    var layerInstructions: [StruccLayerInstruction] = []

}
