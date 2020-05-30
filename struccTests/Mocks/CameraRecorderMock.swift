//
//  CameraRecorderMock.swift
//  struccTests
//
//  Created by Alejandro Arjonilla Garcia on 27/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import Combine
import AVFoundation
@testable import strucc

final class CameraRecorderMock: CameraRecorderProtocol {

    var startSessionCalls = 0
    var stopSessionCalls = 0
    var switchCameraCalls = 0

    lazy var session: AnyPublisher<AVCaptureSession, Never> = mutableSession.eraseToAnyPublisher()
    var mutableSession = CurrentValueSubject<AVCaptureSession, Never>(AVCaptureSession())

    lazy var isRecording: AnyPublisher<Bool, Never> = mutableIsRecording.eraseToAnyPublisher()
    var mutableIsRecording = CurrentValueSubject<Bool, Never>(false)

    var videosUrls: [URL] = []

    func startOrStopRecording() {
        print("startOrStopRecording")
        mutableIsRecording.value = !mutableIsRecording.value
    }

    func reset() {
        videosUrls.removeAll()
    }

    func startSession() {
        startSessionCalls += 1
    }

    func stopSession() {
        stopSessionCalls += 1
    }

    func switchCamera() {
        switchCameraCalls += 1
    }
}
