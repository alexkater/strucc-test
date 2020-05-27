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
        //        videoComposition.customVideoCompositorClass = VideoCompositor.self
        guard
            let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: 1),
            let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 3)
            else { fatalError("Empty video track")}

        let avAssets = Array(urls
            .compactMap { url in
                AVAsset(url: url)
            })
        let asset = avAssets[0]

        guard let videoTrackA = asset.tracks(withMediaType: .video).first,
            let audioTrackA = asset.tracks(withMediaType: .audio).first
        else { fatalError("No tracks to add") }

        let timeRangeA = CMTimeRange(start: .zero, duration: asset.duration)

        do {
            try videoTrack.insertTimeRange(timeRangeA, of: videoTrackA, at: .zero)
            try audioTrack.insertTimeRange(timeRangeA, of: audioTrackA, at: .zero)
        } catch {
            print("Error trying to add track \n\n\(error)")
        }

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: videoTrackA.timeRange.duration)

        let layerInstruction = StruccLayerInstruction(type: .background, assetTrack: videoTrackA)
//        layerInstruction.setTransform(videoTrackA.preferredTransform, at: .zero)
        instruction.layerInstructions = [layerInstruction]

        videoComposition.frameDuration = CMTime(seconds: 1/60, preferredTimescale: 60)
        videoComposition.instructions = [instruction]
        videoComposition.renderSize = CGSize(width: 1080, height: 1920)
        videoComposition.customVideoCompositorClass = VideoCompositor.self

        print("""
             composition.duration.seconds \(composition.duration.seconds)
         """)

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

        print("""
            start \(timeRange.start.seconds)
            end  \(timeRange.end.seconds)
        """)
        videoInstruction.layerInstructions = [layerInstruction]

        return videoInstruction
    }
}

extension Int {
    var isOdd: Bool { self % 2 == 0 }
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
