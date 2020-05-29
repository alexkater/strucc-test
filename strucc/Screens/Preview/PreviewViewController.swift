//
//  PreviewViewController.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Combine

final class PreviewViewController: UIViewController {

    private var viewModel: PreviewViewModelProtocol
    private var collectionview: UICollectionView!
    private var inifiteLoopObserver: NSObjectProtocol?
    private var playerView: UIView!
    private var closeButton: UIButton!
    private let player = AVPlayer()

    var dataSource: CollectionViewDataSourceAndDelegate?
    weak var delegate: CollectionViewDataSourceAndDelegate?
    private var bindings = Set<AnyCancellable>()

    init(viewModel: PreviewViewModelProtocol = PreviewViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.backgroundColor = .clear
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
    }
}

private extension PreviewViewController {

    func addInfiniteLoop(_ player: AVPlayer) {
        inifiteLoopObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
    }

    func setupView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .red

        playerView = UIView(frame: view.bounds)
        playerView.backgroundColor = .clear

        collectionview = createCollectionView()

        closeButton = UIButton()
        closeButton.setImage(#imageLiteral(resourceName: "Exit.pdf"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        [playerView, collectionview, closeButton].forEach { view.addSubview($0) }

        let previewLayer = AVPlayerLayer(player: player)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        playerView.layer.addSublayer(previewLayer)
        addInfiniteLoop(player)
    }

    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: { [weak self] in
            self?.player.pause()
            self?.bindings.forEach { $0.cancel() }
            guard let observer = self?.inifiteLoopObserver else { return }
            NotificationCenter.default.removeObserver(observer, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        })
    }

    func createCollectionView() -> UICollectionView {
        let layout = CollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 24
        layout.callBack = { [weak self] index, scale in
            let cell = self?.collectionview.cellForItem(at: index) as? EditorCollectionViewCell
            cell?.updateScale(scale)
        }

        let collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        dataSource = CollectionViewDataSourceAndDelegate(view: self.view,
                                                         collectionView: collectionview,
                                                         selectionCallback: viewModel.selectionCallbak)

        collectionview.register(EditorCollectionViewCell.self, forCellWithReuseIdentifier: EditorCollectionViewCell.identifier)
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = .clear
        collectionview.decelerationRate = .fast
        collectionview.dataSource = dataSource
        collectionview.delegate = dataSource
        collectionview.tag = 0

        return collectionview
    }

    func setupConstraints() {
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        [
            collectionview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionview.heightAnchor.constraint(equalToConstant: 150)
        ]
            .active()

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        [
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ]
            .active()
    }

    func setupBindings() {

        viewModel.composition
            .sink() { [weak self] (composition) in
                guard let composition = composition else { return }
                self?.updatePlayer(with: composition)
        }.store(in: &bindings)

        viewModel.filters
            .sink { [weak self] (items) in
                self?.dataSource?.items = items
                self?.collectionview.reloadData()
        }
        .store(in: &bindings)

        viewModel.error.sink(receiveValue: show(error:)).store(in: &bindings)
    }

    func show(error: String?) {
        guard let error = error, !error.isEmpty else { return }
        let alert = UIAlertController(title: "Really Sorry",
                                      message: error, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok I understand", style: .default) { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(defaultAction)

        present(alert, animated: true, completion: nil)
    }

    func updatePlayer(with composition: Composition) {
        let playerItem = AVPlayerItem(asset: composition.0)
        playerItem.videoComposition = composition.1
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}
