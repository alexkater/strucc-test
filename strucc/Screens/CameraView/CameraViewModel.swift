//
//  CameraViewModel.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

protocol CameraViewModelProtocol {

    var isButtonSelected: AnyPublisher<Bool, Never> { get }
    var navigate: AnyPublisher<Route?, Never> { get }
    var session: AnyPublisher<AVCaptureSession, Never> { get }

    func recordButtonAction()
    func viewAppear()
    func viewDisappear()
    func switchCamera()
}

final class CameraViewModel: CameraViewModelProtocol {

    lazy var isButtonSelected: AnyPublisher<Bool, Never> = cameraRecorder.isRecording

    lazy var navigate: AnyPublisher<Route?, Never> = mutableNavigate.eraseToAnyPublisher()
    private var mutableNavigate = CurrentValueSubject<Route?, Never>(nil)

    private var bindings = Set<AnyCancellable>()

    private let cameraRecorder: CameraRecorderProtocol
    lazy var session: AnyPublisher<AVCaptureSession, Never> = cameraRecorder.session

    init(_ cameraRecorder: CameraRecorderProtocol = CameraRecorder()) {
        self.cameraRecorder = cameraRecorder
        setupBindings()
    }

    func recordButtonAction() {
        cameraRecorder.startOrStopRecording()
    }

    func viewAppear() {
        cameraRecorder.startSession()
    }

    func viewDisappear() {
        cameraRecorder.stopSession()
    }

    func switchCamera() {
        cameraRecorder.switchCamera()
    }
}

private extension CameraViewModel {

    func setupBindings() {

        isButtonSelected
            .filter { !$0 }
            .sink { [weak self] (_) in
                if let urls = self?.cameraRecorder.videosUrls, urls.count == 2 {
                    self?.cameraRecorder.reset()
                    self?.mutableNavigate.send(Route.preview(urls: urls))
                }
        }.store(in: &bindings)
    }
}
