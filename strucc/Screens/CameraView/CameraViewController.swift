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
    var recordButton: RecordButton!
    private var bindings = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel
            .session
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (session) in
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.frame = self?.view.bounds ?? .zero
                previewLayer.videoGravity = .resizeAspectFill
                self?.view.layer.addSublayer(previewLayer)
                self?.setupView()
                self?.setupConstraints()
                self?.setupBindings()
            })
            .store(in: &bindings)
    }

    @objc func recordButtonTapped() {
        viewModel.recordButtonAction()
    }
}

private extension CameraViewController {

    func setupView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .gray
        recordButton = RecordButton(width: 74)
        view.addSubview(recordButton)
        view.bringSubviewToFront(recordButton)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.backgroundColor = .clear
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

        viewModel.isButtonSelected
            .receive(on: RunLoop.main)
            .assign(to: \.isSelected, on: recordButton)
            .store(in: &bindings)

        viewModel.navigate
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (value) in
                self?.show(value.controller, sender: nil)
            })
            .store(in: &bindings)
    }
}
