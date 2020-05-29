//
//  ViewController.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit
import Combine
import AVFoundation

class CameraViewController: UIViewController {

    private var viewModel: CameraViewModelProtocol = CameraViewModel()
    private var cameraView: UIView!
    var recordButton: RecordButton!
    private var bindings = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        setupBindings()

        #if DEBUG
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureTap))
        cameraView.addGestureRecognizer(longPressGesture)
        #endif
    }

    #if DEBUG
    @objc func longGestureTap() {
        let controller = PreviewViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    #endif

    @objc func recordButtonTapped() {
        viewModel.recordButtonAction()
    }
}

private extension CameraViewController {

    func setupView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .gray
        cameraView = UIView(frame: view.bounds)
        recordButton = RecordButton(width: 74)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.backgroundColor = .clear

        [cameraView, recordButton].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
            recordButton.widthAnchor.constraint(equalToConstant: 74),
            recordButton.heightAnchor.constraint(equalToConstant: 74)
        ]

        constraints.forEach { $0.isActive = true }
    }

    func setupBindings() {

        viewModel
            .session
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (session) in
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.frame = self?.view.bounds ?? .zero
                previewLayer.videoGravity = .resizeAspectFill
                self?.cameraView.layer.addSublayer(previewLayer)
            })
            .store(in: &bindings)

        viewModel.isButtonSelected
            .receive(on: RunLoop.main)
            .assign(to: \.isSelected, on: recordButton)
            .store(in: &bindings)

        viewModel.navigate
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (value) in
                let controller = value.controller
                controller.modalPresentationStyle = .fullScreen
                self?.present(controller, animated: true, completion: nil)
            })
            .store(in: &bindings)
    }
}
