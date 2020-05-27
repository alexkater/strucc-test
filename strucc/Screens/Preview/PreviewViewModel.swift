//
//  PreviewViewModel.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import AVFoundation

typealias VideoCompositionCompletion = (AVComposition, AVVideoComposition?) -> Void

protocol PreviewViewModelProtocol {

    func get(_ completion: @escaping VideoCompositionCompletion)
}

final class PreviewViewModel: PreviewViewModelProtocol {

    private let urls: [URL]

    init(urls: [URL] = urlsDemo) {
        self.urls = urls
    }

    func get(_ completion: @escaping VideoCompositionCompletion) {
        let videoEditor = VideoEditor(urls)
        videoEditor.createComposition(completion)
    }
}

#if DEBUG
let urlsDemo = [
    "video1",
    "video2"
//    ,
//    "/private/var/mobile/Containers/Data/Application/10BC6128-2AC2-4DAB-BB20-FA7F3AA6B69C/tmp/2020-05-27 4:09:03 PM +0000-strucc.mov"
//    ,
//    "video3"
    ]
    .compactMap { videoName -> URL? in
        guard let path = Bundle.main.path(forResource: videoName, ofType: "MOV") else {
            debugPrint(" not found")
            return nil
        }
        return URL(fileURLWithPath: path)
}

var audioUrl: URL {
    guard let path = Bundle.main.path(forResource: "audio", ofType: "mp3") else {
    fatalError("polpsdfasfdalkgnasgf")
    }
    return URL(fileURLWithPath: path)
}
#endif
