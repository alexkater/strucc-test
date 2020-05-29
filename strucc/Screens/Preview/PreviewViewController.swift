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

        viewModel.get { [weak self] (composition, videoComposition) in
            let playerItem = AVPlayerItem(asset: composition)
            playerItem.videoComposition = videoComposition

            let player = AVPlayer(playerItem: playerItem)
            let previewLayer = AVPlayerLayer(player: player)
            previewLayer.frame = self?.view.bounds ?? .zero
            previewLayer.videoGravity = .resizeAspectFill
            self?.playerView.layer.addSublayer(previewLayer)
            self?.addInfiniteLoop(player)

            player.play()
        }

        viewModel.filters
            .sink { [weak self] (items) in
                self?.dataSource?.items = items
                self?.collectionview.reloadData()
        }
        .store(in: &bindings)
    }

    deinit {
        guard let observer = inifiteLoopObserver else { return }
        NotificationCenter.default.removeObserver(observer, name: .AVPlayerItemDidPlayToEndTime, object: nil)
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
        self.view.backgroundColor = .black

        playerView = UIView(frame: view.bounds)
        playerView.backgroundColor = .clear

        collectionview = createCollectionView()

        closeButton = UIButton()
        closeButton.setImage(#imageLiteral(resourceName: "Exit.pdf"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        [playerView, collectionview, closeButton].forEach { view.addSubview($0) }
    }

    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
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
}
