//
//  VideoEditorMock.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 30/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
@testable import strucc

final class VideoEditorMock: VideoEditorProtocol {
    var futureMock: CompositionFuture?

    func createComposition(urls: [URL]) -> CompositionFuture {
        return futureMock ?? CompositionFuture { $0(.failure(.cannotRenderPixelBuffer)) }
    }
}
