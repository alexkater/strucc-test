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
    var error: AnyPublisher<String?, Never> { get }
    var helperText: AnyPublisher<String?, Never> { get }

    func recordButtonAction()
    func viewAppear()
    func viewDisappear()
    func switchCamera()
}

final class CameraViewModel: CameraViewModelProtocol {

    lazy var isButtonSelected: AnyPublisher<Bool, Never> = cameraRecorder.isRecording

    lazy var navigate: AnyPublisher<Route?, Never> = mutableNavigate.eraseToAnyPublisher()
    private var mutableNavigate = CurrentValueSubject<Route?, Never>(nil)

    lazy var error: AnyPublisher<String?, Never> = mutableError.eraseToAnyPublisher()
    private var mutableError = CurrentValueSubject<String?, Never>(nil)

    lazy var helperText: AnyPublisher<String?, Never> = mutableHelperText.eraseToAnyPublisher()
    private var mutableHelperText = CurrentValueSubject<String?, Never>(nil)

    private var bindings = Set<AnyCancellable>()

    private let cameraRecorder: CameraRecorderProtocol
    lazy var session: AnyPublisher<AVCaptureSession, Never> = cameraRecorder.session

    init(_ cameraRecorder: CameraRecorderProtocol = CameraRecorder()) {
        self.cameraRecorder = cameraRecorder
        setupBindings()
    }

    func recordButtonAction() {
        do {
            try cameraRecorder.startOrStopRecording()
        } catch {
            mutableError.value = error.localizedDescription
        }
    }

    func viewAppear() {
        cameraRecorder.startSession()
        mutableHelperText.value = "Record 2 videos!"
    }

    func viewDisappear() {
        cameraRecorder.stopSession()
    }

    func switchCamera() {
        do {
            try cameraRecorder.switchCamera()
        } catch {
            mutableError.value = error.localizedDescription
        }
    }
}

private extension CameraViewModel {

    func setupBindings() {

        isButtonSelected
            .filter { !$0 }
            .sink { [weak self] (_) in

                if self?.cameraRecorder.videosUrls.count == 1 {
                    self?.mutableHelperText.value = "Record another one :)"
                }

                if let urls = self?.cameraRecorder.videosUrls, urls.count == 2 {
                    self?.mutableHelperText.value = "Editing time!"
                    self?.cameraRecorder.reset()
                    self?.mutableNavigate.send(Route.preview(urls: urls))
                }
        }.store(in: &bindings)
    }
}
