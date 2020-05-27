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

final class PreviewViewController: UIViewController {

    private var viewModel: PreviewViewModelProtocol
    private var collectionView: UICollectionView!

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

        viewModel.get { [weak self] (composition, videoComposition) in
            let playerItem = AVPlayerItem(asset: composition)
            playerItem.videoComposition = videoComposition

            let player = AVPlayer(playerItem: playerItem)
            let previewLayer = AVPlayerLayer(player: player)
            previewLayer.frame = self?.view.bounds ?? .zero
            previewLayer.videoGravity = .resizeAspectFill
            self?.view.layer.addSublayer(previewLayer)
            player.play()
        }
    }
}

private extension PreviewViewController {

    func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.backgroundColor = .red
    }
}
