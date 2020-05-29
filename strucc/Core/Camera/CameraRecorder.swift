//
//  CameraView.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import Combine

enum CameraViewError: Error {
    case cameraBuild, audioBuild, impossibleCreateFileURL
}

protocol CameraRecorderProtocol {
    var session: AnyPublisher<AVCaptureSession, Never> { get }
    var isRecording: AnyPublisher<Bool, Never> { get }

    var videosUrls: [URL] { get }

    func startOrStopRecording()
    func reset()
    func startSession()
    func stopSession()
}

class CameraRecorder: NSObject, CameraRecorderProtocol {

    lazy var session: AnyPublisher<AVCaptureSession, Never> = mutableSession.eraseToAnyPublisher()
    private var mutableSession = CurrentValueSubject<AVCaptureSession, Never>(AVCaptureSession())

    private var captureSession: AVCaptureSession { mutableSession.value }

    lazy var isRecording: AnyPublisher<Bool, Never> = mutableIsRecording.eraseToAnyPublisher()
    private var mutableIsRecording = CurrentValueSubject<Bool, Never>(false)

    private let cameraPosition: AVCaptureDevice.Position
    private let sampleBufferQueue = DispatchQueue(label: "com.aarjinc.strucc.SampleBuffer", qos: .userInitiated)
    private let movieOutput = AVCaptureMovieFileOutput()
    private var activeInput: AVCaptureDeviceInput!
    var videosUrls: [URL] = []

    init(cameraPosition: AVCaptureDevice.Position = .back) {
        self.cameraPosition = cameraPosition
        super.init()
        do {
            try prepareSession()
        } catch {
            print(error)
        }
    }

    func reset() {
        videosUrls.removeAll()
    }

    func startOrStopRecording() {
        mutableIsRecording.value ? stopRecording(): startRecording()
    }

    func startSession() {
        if !captureSession.isRunning {
            sampleBufferQueue.async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            sampleBufferQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
}

private extension CameraRecorder {

    func prepareSession() throws {
        try prepareVideo()
        try prepareAudio()

        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
    }

    func prepareVideo() throws {
        captureSession.sessionPreset = .hd1920x1080

        let cameraDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInMicrophone], mediaType: .video, position: cameraPosition)
        guard let camera = cameraDiscovery.devices.first
            else { throw CameraViewError.cameraBuild }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            throw error
        }
    }

    func prepareAudio() throws {
        guard let microphone = AVCaptureDevice.default(for: .audio)
            else { throw CameraViewError.audioBuild }

        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            throw error
        }
    }
}

// MARK: - Recording
private extension CameraRecorder {

    func startRecording() {
      if !movieOutput.isRecording {
        let connection = movieOutput.connection(with: .video)
        if connection?.isVideoOrientationSupported == true {
            connection?.videoOrientation = .portrait
        }

        if connection?.isVideoStabilizationSupported == true {
            connection?.preferredVideoStabilizationMode = .auto
        }

        do {
            let url = try getNewURL()
            movieOutput.startRecording(to: url, recordingDelegate: self)
        } catch {
            // TODO: @aarjonilla Do something here with the error?
            print(error)
        }

      } else {
        stopRecording()
      }
    }

    func stopRecording() {
      if movieOutput.isRecording {
        movieOutput.stopRecording()
      }
    }

    func getNewURL() throws -> URL {
        let directory = NSTemporaryDirectory()
        guard !directory.isEmpty else { throw CameraViewError.impossibleCreateFileURL }
        let path = directory.appending("\(Date().description)-strucc.mov")
        return URL(fileURLWithPath: path)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraRecorder: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        videosUrls.append(outputFileURL)
        mutableIsRecording.value = false
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        mutableIsRecording.value = true
    }
}
