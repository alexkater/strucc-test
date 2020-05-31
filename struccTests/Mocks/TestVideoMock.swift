//
//  TestVideoMock.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 31/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation

struct TestVideoMock {

    static var defaultUrls: [URL] {
        #if DEBUG
        return [
            "video1",
            "video2"
            ]
            .compactMap { videoName -> URL? in
                guard let path = Bundle.main.path(forResource: videoName, ofType: "MOV") else {
                    debugPrint(" not found")
                    return nil
                }
                return URL(fileURLWithPath: path)
        }
        #else
        return []
        #endif
    }
}
