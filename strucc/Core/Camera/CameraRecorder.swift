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

enum CameraError: Error {
    case cameraBuild, audioBuild, impossibleCreateFileURL
}

protocol CameraRecorderProtocol {
    var session: AnyPublisher<AVCaptureSession, Never> { get }
    var isRecording: AnyPublisher<Bool, Never> { get }

    var videosUrls: [URL] { get }

    func startOrStopRecording() throws
    func reset()
    func startSession()
    func stopSession()
    func switchCamera() throws
}

class CameraRecorder: NSObject, CameraRecorderProtocol {

    lazy var session: AnyPublisher<AVCaptureSession, Never> = mutableSession.eraseToAnyPublisher()
    private var mutableSession = CurrentValueSubject<AVCaptureSession, Never>(AVCaptureSession())

    private var captureSession: AVCaptureSession { mutableSession.value }

    lazy var isRecording: AnyPublisher<Bool, Never> = mutableIsRecording.eraseToAnyPublisher()
    private var mutableIsRecording = CurrentValueSubject<Bool, Never>(false)

    private var cameraPosition: AVCaptureDevice.Position
    private let sampleBufferQueue = DispatchQueue(label: "com.aarjinc.strucc.SampleBuffer", qos: .userInitiated)
    private let movieOutput = AVCaptureMovieFileOutput()
    private var activeInput: AVCaptureDeviceInput?
    var videosUrls: [URL] = []

    init(cameraPosition: AVCaptureDevice.Position = .back) {
        self.cameraPosition = cameraPosition
        super.init()

        #if !targetEnvironment(simulator)
          do {
              try prepareSession()
          } catch {
              print(error)
          }
        #endif
    }

    func reset() {
        videosUrls.removeAll()
    }

    func startOrStopRecording() throws {
        mutableIsRecording.value ? stopRecording(): try startRecording()
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

    func switchCamera() throws {
        cameraPosition = cameraPosition == .back ? .front: .back
        try prepareVideo()
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
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1920x1080

        let cameraDiscovery = AVCaptureDevice
            .DiscoverySession(deviceTypes:
                [.builtInDualCamera,
                 .builtInWideAngleCamera,
                 .builtInMicrophone],
                              mediaType: .video, position: cameraPosition)

        guard let camera = cameraDiscovery.devices.first
            else { throw CameraError.cameraBuild }

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            if let activeInput = activeInput {
                captureSession.removeInput(activeInput)
            }

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            throw error
        }

        captureSession.commitConfiguration()
    }

    func prepareAudio() throws {
        guard let microphone = AVCaptureDevice.default(for: .audio)
            else { throw CameraError.audioBuild }

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

    func startRecording() throws {
      if !movieOutput.isRecording {
        let connection = movieOutput.connection(with: .video)
        if connection?.isVideoOrientationSupported == true {
            connection?.videoOrientation = .portrait
        }

        if connection?.isVideoStabilizationSupported == true {
            connection?.preferredVideoStabilizationMode = .auto
        }

        let url = try getNewURL()
        movieOutput.startRecording(to: url, recordingDelegate: self)

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
        guard !directory.isEmpty else { throw CameraError.impossibleCreateFileURL }
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
