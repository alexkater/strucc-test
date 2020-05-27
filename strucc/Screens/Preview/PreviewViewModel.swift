//
//  PreviewViewModel.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import AVFoundation

protocol PreviewViewModelProtocol {

    func get(_ completion: (AVComposition, AVVideoComposition) -> Void)
}

final class PreviewViewModel: PreviewViewModelProtocol {

    private let urls: [URL]

    init(urls: [URL] = urlsDemo) {
        self.urls = urls
        print(urls)
    }

    func get(_ completion: (AVComposition, AVVideoComposition) -> Void) {
        VideoEditor(urls)
            .createComposition(completion)
    }
}

#if DEBUG
let urlsDemo = [
    "video1",
    "video2"
    ]
    .compactMap { videoName -> URL? in
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            debugPrint(" not found")
            return nil
        }
        return URL(fileURLWithPath: path)
}
#endif
