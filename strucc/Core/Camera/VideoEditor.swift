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

    func createComposition(_ completion: @escaping VideoCompositionCompletion) {

        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()
        let instructionOne = AVMutableVideoCompositionInstruction()
        let instructionTwo = AVMutableVideoCompositionInstruction()
        videoComposition.customVideoCompositorClass = VideoCompositor.self

        guard
            let videoTrackOne = composition.addMutableTrack(withMediaType: .video, preferredTrackID: 1),
            let videoTrackTwo = composition.addMutableTrack(withMediaType: .video, preferredTrackID: 2),
            let audioTrackOne = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 3),
            let audioTrackTwo = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 4)
            else { fatalError("Empty video track")}

        let avAssets = Array(urls
            .compactMap { url in
                AVAsset(url: url)
            })

        let minDuration = avAssets
            .map { $0.duration.seconds }
            .sorted(by: <)
            .first ?? 0
        let minDurationTime = CMTime(seconds: minDuration, preferredTimescale: 600)

        avAssets.indices.forEach { (indice) in
            let avAsset = avAssets[indice]
            let videoTrack = indice.isOdd ? videoTrackOne: videoTrackTwo
            let audioTrack = indice.isOdd ? audioTrackOne: audioTrackTwo

            guard let videoAssetTrack = avAsset.tracks(withMediaType: .video).first,
                let audioAssetTrack = avAsset.tracks(withMediaType: .audio).first
                else { fatalError("No tracks to add") }

            let timeRange = CMTimeRange(start: .zero, duration: minDurationTime)

            do {
                try videoTrack.insertTimeRange(timeRange, of: videoAssetTrack, at: .zero)
                try audioTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: .zero)
            } catch {
                print("Error trying to add track \n\n\(error)")
            }
        }

        instructionOne.timeRange = CMTimeRange(start: .zero, duration: minDurationTime)
        instructionTwo.timeRange = CMTimeRange(start: .zero, duration: minDurationTime)

        let layerInstructionOne = StruccLayerInstruction(type: .background, assetTrack: videoTrackOne)
        let layerInstructionTwo = StruccLayerInstruction(type: .foreground, assetTrack: videoTrackTwo)

        instructionOne.layerInstructions = [layerInstructionOne, layerInstructionTwo]

        videoComposition.frameDuration = CMTime(seconds: 1/60, preferredTimescale: 60)
        videoComposition.instructions = [instructionOne]
            .sorted(by: { $0.timeRange.duration.seconds < $1.timeRange.duration.seconds })
        videoComposition.renderSize = CGSize(width: 1080, height: 1920)

        completion(composition, videoComposition)
    }

    private func addVideoTrack(indice: Int, track: AVMutableCompositionTrack, asset: AVAsset) -> AVVideoCompositionInstruction {

        guard let videoTrack = asset.tracks(withMediaType: .video).first else { fatalError("No tracks to add") }
        let timescale: CMTimeScale = 600
        let startTime: CMTime = CMTime(seconds: track.timeRange.duration.seconds, preferredTimescale: timescale)
        let duration: CMTime = videoTrack.timeRange.duration

        let timeRange: CMTimeRange = CMTimeRange(start: startTime,
                                                 duration: duration)
        do {
            try track.insertTimeRange(timeRange, of: videoTrack, at: timeRange.start)
        } catch {
            print("Error trying to add track \(videoTrack)\n\n\(error)")
        }

        track.preferredTransform = videoTrack.preferredTransform
        let videoInstruction = AVMutableVideoCompositionInstruction()
        videoInstruction.timeRange = timeRange

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.setTransform(track.preferredTransform, at: .zero)
        layerInstruction.setOpacityRamp(fromStartOpacity: 1, toEndOpacity: 0, timeRange: timeRange)

        videoInstruction.layerInstructions = [layerInstruction]

        return videoInstruction
    }
}

extension CMTime {
    static func + (lhs: CMTime, rhs: Double) -> CMTime {
        return CMTimeAdd(lhs, CMTime(seconds: rhs, preferredTimescale: 600))
    }

    static func - (lhs: CMTime, rhs: Double) -> CMTime {
        return CMTimeSubtract(lhs, CMTime(seconds: rhs, preferredTimescale: 600))
    }
}

extension Int64 {

    var cmTime: CMTime { CMTime(value: self, timescale: 600)}
}
