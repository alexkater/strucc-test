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
        setupView()
        createPreview()

        viewModel.get { (composition, videoComposition) in
            let playerItem = AVPlayerItem(asset: composition)
            playerItem.videoComposition = videoComposition

            let player = AVPlayer(playerItem: playerItem)
            let previewLayer = AVPlayerLayer(player: player)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PreviewViewController {

    func createPreview() {
        let player = AVPlayer(playerItem: nil)
        let previewLayer = AVPlayerLayer(player: player)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.backgroundColor = .red
    }
}
