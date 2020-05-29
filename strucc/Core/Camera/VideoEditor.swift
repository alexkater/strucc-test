//
//  VideoEditor.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 27/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import AVFoundation
import Combine

protocol VideoEditorProtocol {

    func createComposition(urls: [URL]) -> CompositionFuture
}

class VideoEditor: VideoEditorProtocol {

    func createComposition(urls: [URL]) -> CompositionFuture {
        
        CompositionFuture { [weak self] promise in
            guard let strongSelf = self else {
                promise(.failure(.selfDeinitialized))
                return
            }

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
                else {
                    promise(.failure(.cantTakeTracks))
                    return
            }

            let avAssets = Array(urls.compactMap { url in AVAsset(url: url) })

            let minDuration = avAssets
                .map { $0.duration.seconds }
                .sorted(by: <)
                .first ?? 0

            let minDurationTime = CMTime(seconds: minDuration, preferredTimescale: 600)

            avAssets.indices.forEach { (indice) in
                let avAsset = avAssets[indice]
                let videoTrack = indice.isOdd ? videoTrackOne: videoTrackTwo
                let audioTrack = indice.isOdd ? audioTrackOne: audioTrackTwo

                // TODO: @aarjonilla Added func
                do {
                    try strongSelf.addAssetToTrack(avAsset, videoTrack: videoTrack, audioTrack: audioTrack, duration: minDurationTime)
                } catch {
                    promise(.failure(.cantTakeAVAssetTracks))
                    return
                }
            }

            strongSelf.addInstructions(instructionOne, minDurationTime, instructionTwo, videoTrackOne, videoTrackTwo)

            videoComposition.frameDuration = CMTime(seconds: 1/60, preferredTimescale: 60)
            videoComposition.instructions = [instructionOne]
                .sorted(by: { $0.timeRange.duration.seconds < $1.timeRange.duration.seconds })
            videoComposition.renderSize = CGSize(width: 1080, height: 1920)

            let returnComposition = (composition, videoComposition)
            promise(.success(returnComposition))
        }
    }
}

private extension VideoEditor {

    func addAssetToTrack(_ avAsset: AVAsset, videoTrack: AVMutableCompositionTrack,
                         audioTrack: AVMutableCompositionTrack, duration: CMTime) throws {
        guard let videoAssetTrack = avAsset.tracks(withMediaType: .video).first,
            let audioAssetTrack = avAsset.tracks(withMediaType: .audio).first
            else { throw StruccError.cantTakeAVAssetTracks }

        let timeRange = CMTimeRange(start: .zero, duration: duration)

        try videoTrack.insertTimeRange(timeRange, of: videoAssetTrack, at: .zero)
        try audioTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: .zero)
    }

    func addInstructions(_ instructionOne: AVMutableVideoCompositionInstruction, _ minDurationTime: CMTime, _ instructionTwo: AVMutableVideoCompositionInstruction, _ videoTrackOne: AVMutableCompositionTrack, _ videoTrackTwo: AVMutableCompositionTrack) {
        instructionOne.timeRange = CMTimeRange(start: .zero, duration: minDurationTime)
        instructionTwo.timeRange = CMTimeRange(start: .zero, duration: minDurationTime)

        let layerInstructionOne = StruccLayerInstruction(type: .background, assetTrack: videoTrackOne)
        let layerInstructionTwo = StruccLayerInstruction(type: .foreground, assetTrack: videoTrackTwo)

        instructionOne.layerInstructions = [layerInstructionOne, layerInstructionTwo]
    }
}
