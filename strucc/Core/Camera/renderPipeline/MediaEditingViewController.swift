//
//  MediaEditingViewController.swift
//  VideoPipelineKit_Example
//
//  Created by Patrick Tescher on 9/21/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import AVKit
import MetalKit
import GLKit

class MediaEditingViewController: UIViewController, PlayerItemPipelineDisplayLinkDelegate {
    var metalOutput: MTKView!

    var playerObserver: Any?
    var displayLink: PlayerItemPipelineDisplayLink?

    lazy var player: AVQueuePlayer = {
        let player = AVQueuePlayer()
        self.playerObserver = player.observe(\.currentItem, changeHandler: { [weak self] (player, change) in
            if let displayLink = self?.displayLink {
                displayLink.end()
                if let item = change.oldValue, item?.outputs.contains(displayLink.videoOutput) == true {
                    item?.remove(displayLink.videoOutput)
                }
            }

            if let item = player.currentItem, let renderPipeline = self?.renderPipeline {
                let displayLink = item.addDisplayLink(for: renderPipeline)
                displayLink.delegate = self
                displayLink.start()
                self?.displayLink = displayLink
            }
        })
        return player
    }()

    let instantFilter: CIFilter = {
        let filter = CIFilter(name: "CIPhotoEffectInstant")!
        return filter
    }()

    let monoFilter: CIFilter = {
        let filter = CIFilter(name: "CIPhotoEffectMono")!
        return filter
    }()

    let skinFilter: CIFilter = {
        let filter = CIFilter(name: "CIMotionBlur")!
        return filter
    }()

    lazy var renderPipeline: RenderPipeline = {
        let renderPipeline = RenderPipeline(size: cropRect.size)
        renderPipeline.filters.append(self.skinFilter)
        renderPipeline.size = self.cropRect.size
        return renderPipeline
    }()

    var looper: AVPlayerLooper?

    var cropRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 607.5, height: 1080))

    var playerItem: AVPlayerItem? {
        didSet {
            guard let playerItem = playerItem else {
                looper = nil
                player.removeAllItems()
                return
            }

            player.insert(playerItem, after: nil)
            looper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metalOutput = MTKView(frame: view.bounds, device: renderPipeline.device)
        view.addSubview(metalOutput)
        renderPipeline.add(videoOutput: metalOutput)

        let asset = AVAsset(url: urlsDemo.first!)
        playerItem = AVPlayerItem(asset: asset)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }

    // MARK: - PlayerItemPipelineDisplayLinkDelegate

    func willRender(_ image: CIImage, through pipeline: RenderPipeline) {

    }
}
