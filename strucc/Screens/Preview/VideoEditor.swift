//
//  VideoEditor.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 27/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import AVFoundation

class VideoEditor {

    private let urls: [URL]

    init(_ urls: [URL]) {
        self.urls = urls
    }

    func createComposition(_ completion: (AVComposition, AVVideoComposition) -> Void) {
        let composition = AVMutableComposition()
        var videoSize = CGSize.zero
        var layerInstructions = [AVVideoCompositionLayerInstruction]()
        var instructions = [AVVideoCompositionInstructionProtocol]()
        let instruction = AVMutableVideoCompositionInstruction()

        urls.forEach { (videoURL) in

            let asset = AVURLAsset(url: videoURL)

            guard
                let compositionTrack = composition.addMutableTrack(
                    withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                let assetTrack = asset.tracks(withMediaType: .video).first
                else {
                    print("Something is wrong with the asset.")
                    return
            }
            compositionTrack.preferredTransform = assetTrack.preferredTransform
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            try? compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
            videoSize = assetTrack.naturalSize

            // TODO: @aarjonilla fix this
            instruction.timeRange = CMTimeRange(
              start: .zero,
              duration: composition.duration)

            instructions.append(instruction)
            let layerInstruction = compositionLayerInstruction(
              for: compositionTrack,
              assetTrack: assetTrack)

            layerInstructions.append(layerInstruction)
        }

        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)

        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        outputLayer.addSublayer(videoLayer)

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
//        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
//          postProcessingAsVideoLayer: videoLayer,
//          in: outputLayer)

        videoComposition.instructions = instructions
        instruction.layerInstructions = layerInstructions

        completion(composition, videoComposition)
    }

    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
      let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
      let transform = assetTrack.preferredTransform

      instruction.setTransform(transform, at: .zero)

      return instruction
    }
}
