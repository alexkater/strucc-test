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
    private var currentComposition: AVComposition?

    init(viewModel: PreviewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
        setupConstraints()
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.backgroundColor = .clear
        }
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

        [playerView, collectionview, closeButton].forEach { view.addSubview($0) }

        let previewLayer = AVPlayerLayer(player: player)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        playerView.layer.addSublayer(previewLayer)
        addInfiniteLoop(player)

        playerView.alpha = 0

        #if DEBUG
        player.volume = 0
        #endif
        UIView.animate(withDuration: 1) {
            self.playerView.alpha = 1
        }
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
            collectionview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            collectionview.heightAnchor.constraint(equalToConstant: 110)
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

        closeButton.publisher(for: .touchUpInside).sink { [weak self] (_) in
            self?.player.pause()
            self?.dismiss(animated: true, completion: {
                self?.bindings.forEach { $0.cancel() }
                guard let observer = self?.inifiteLoopObserver else { return }
                NotificationCenter.default.removeObserver(observer, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            })
        }.store(in: &bindings)

        viewModel.composition
            .delay(for: 0.3, scheduler: RunLoop.main)
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

        viewModel.error
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] (error) in
                self?.show(error: error)
            })
            .store(in: &bindings)
    }

    func updatePlayer(with composition: Composition) {
        let playerItem = AVPlayerItem(asset: composition.0)
        playerItem.videoComposition = composition.1
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}
