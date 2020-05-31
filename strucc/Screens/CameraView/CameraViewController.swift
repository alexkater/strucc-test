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

    private var viewModel: CameraViewModelProtocol
    private var cameraView: UIView!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var transition: TransitionAnimator!
    var recordButton: RecordButton!
    var switchCameraButton: UIButton!

    private var bindings = Set<AnyCancellable>()

    init(viewModel: CameraViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
        setupConstraints()
        setupBindings()

        transition = TransitionAnimator(0.8, originFrame: recordButton.frame)

        #if DEBUG
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureTap))
        cameraView.addGestureRecognizer(longPressGesture)
        #endif
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    @objc func longGestureTap(gestureReconizer: UILongPressGestureRecognizer) {
        guard gestureReconizer.state == .ended else { return }
        presentRoute(.preview(urls: TestVideoMock.defaultUrls))
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

        switchCameraButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 48, height: 48)))
        switchCameraButton.setImage(#imageLiteral(resourceName: "FlipCamera.pdf"), for: .normal)

        [cameraView, recordButton, switchCameraButton].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        [recordButton, switchCameraButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        [
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            recordButton.widthAnchor.constraint(equalToConstant: 74),
            recordButton.heightAnchor.constraint(equalToConstant: 74)
            ].active()

        [
            switchCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            switchCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ].active()

        view.layoutSubviews()
    }

    func setupBindings() {

        recordButton
            .publisher(for: .touchUpInside)
            .throttle(for: 1.5, scheduler: RunLoop.main, latest: false)
            .sink { [weak self] (_) in
                self?.viewModel.recordButtonAction()
        }
        .store(in: &bindings)

        switchCameraButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] (_) in
                self?.viewModel.switchCamera()
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

            viewModel.error
                .compactMap { $0 }
                .sink(receiveValue: { [weak self] (error) in
                    self?.show(error: error)
                })
                .store(in: &bindings)

        viewModel.helperText
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] (text) in
                self?.addAnimatedText(text)
            })
            .store(in: &bindings)
    }

    func presentRoute(_ route: Route) {
        let controller = route.controller
        controller.modalPresentationStyle = .currentContext
        controller.transitioningDelegate = self
        present(controller, animated: true, completion: nil)
    }
}

extension CameraViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        transition.presenting = true
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

private extension CameraViewController {

    func addAnimatedText(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.postGrotestBold(30)
        label.textColor = .white
        label.alpha = 0

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        [
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ].active()

        UIView.animate(withDuration: 1, animations: {
            label.frame.size = CGSize(width: self.view.frame.width, height: 100)
            label.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.5,
                           delay: 1,
                           animations: {
                let scaleTransform = CGAffineTransform(scaleX: 4, y: 4)
                label.transform = scaleTransform
                label.alpha = 0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        }
    }
}
