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
    private var recordButton: RecordButton!
    private var previewLayer: AVCaptureVideoPreviewLayer!

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewDisappear()
    }

    #if DEBUG
    @objc func longGestureTap() {
        presentRoute(.preview(urls: []))
    }
    #endif
}

private extension CameraViewController {

    func setupView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .gray

        previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView = UIView(frame: view.bounds)
        cameraView.layer.addSublayer(previewLayer)

        recordButton = RecordButton(width: 74)
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

        recordButton
            .publisher(for: .touchUpInside)
            .throttle(for: 2, scheduler: RunLoop.main, latest: false)
            .sink { [weak self] (_) in
                self?.viewModel.recordButtonAction()
        }
        .store(in: &bindings)

        viewModel
            .session
            .sink(receiveValue: { [weak self] (session) in
                self?.previewLayer.session = session
            })
            .store(in: &bindings)

        viewModel.isButtonSelected
            .receive(on: RunLoop.main)
            .assign(to: \.isSelected, on: recordButton)
            .store(in: &bindings)

        viewModel.navigate
            .compactMap { $0 }
            .delay(for: 1, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] (value) in
                self?.presentRoute(value)
            })
            .store(in: &bindings)
    }

    func presentRoute(_ route: Routes) {
        let controller = route.controller
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
}
