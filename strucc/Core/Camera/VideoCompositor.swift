//
//  VideoCompositor.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 27/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

class VideoCompositor: NSObject, AVFoundation.AVVideoCompositing {

    private let filterProvider: FilterProviderProtocol

    func getRandomFilter(seconds: Double, inputImage: CIImage) -> CIImage? {
        // TODO: @aarjonilla check if makes sense to use non typed way
        let filter: CIFilter & CIPhotoEffect
        switch seconds {
        case 0...2:
            filter = CIFilter.photoEffectNoir()
        case 2...5:
            filter = CIFilter.photoEffectInstant()
        case 5...9:
            filter = CIFilter.photoEffectChrome()
        default:
            filter = CIFilter.photoEffectMono()
        }

        filter.inputImage = inputImage
        return filter.outputImage
    }

    override public init() {
        self.filterProvider = FilterProvider.shared
        super.init()
    }

    static let colorMatrixFilter: CIFilter = {
        return CIFilter(name: "CIColorMatrix")!
    }()

    lazy var imageContext: CIContext = {
        return CIContext()
    }()

    private let renderContextQueue: DispatchQueue = DispatchQueue(label: "strucc.rendercontextqueue")
    private let renderingQueue: DispatchQueue = DispatchQueue(label: "strucc.renderingqueue")
    private var renderContextDidChange = false
    private var shouldCancelAllRequests = false
    private var renderContext: AVVideoCompositionRenderContext?

    public var sourcePixelBufferAttributes: [String: Any]? {
        return [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                String(kCVPixelBufferOpenGLESCompatibilityKey): true]
    }

    public var requiredPixelBufferAttributesForRenderContext: [String: Any] {
        return [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                String(kCVPixelBufferOpenGLESCompatibilityKey): true]
    }

    public func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderContextQueue.sync { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.renderContext = newRenderContext
            strongSelf.renderContextDidChange = true
        }
    }

    public func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {

        autoreleasepool {
            renderingQueue.async { [weak self] in
                guard let strongSelf = self else { return }

                guard request.sourceTrackIDs.count > 0 else {
                    request.finish(with: StruccError.noSourceTracks)
                    return
                }

                guard let instruction = request.videoCompositionInstruction as? VideoCompositionInstruction else {
                    request.finish(with: StruccError.noInstruction)
                    return
                }

                guard let pixelBuffer = request.renderContext.newPixelBuffer() else {
                    request.finish(with: StruccError.cannotRenderPixelBuffer)
                    return
                }

                strongSelf.render(request, instruction: instruction, pixelBuffer: pixelBuffer)
            }
        }
    }

    public func cancelAllPendingVideoCompositionRequests() {
      renderingQueue.sync { shouldCancelAllRequests = true }
      renderingQueue.async { [weak self] in
        self?.shouldCancelAllRequests = false
      }
    }

    func render(_ request: AVAsynchronousVideoCompositionRequest,
                instruction: VideoCompositionInstruction,
                pixelBuffer: CVPixelBuffer) {

        let backgroundColor = CIColor(cgColor: UIColor.clear.cgColor)
        let contextExtent = CGRect(origin: CGPoint.zero, size: request.renderContext.size)
        let backgroundImage = CIImage(color: backgroundColor).cropped(to: contextExtent)

        let composedImage = instruction.layerInstructions
            .reduce(backgroundImage, { (composedImage, instruction) -> CIImage in
            guard let layerImageBuffer = request.sourceFrame(byTrackID: instruction.trackID) else {
                request.finish(withComposedVideoFrame: pixelBuffer)
                return composedImage
                }

                let transformedImage = CIImage(cvPixelBuffer: layerImageBuffer)
                    .transformed(by: request.renderContext.renderTransform)
                    .applying(orientationTransform: .init(rotationAngle: 3 * .pi / 2), mirrored: false)

                return instruction.apply(image: transformedImage, composedImage: composedImage, contextExtent: contextExtent) ?? backgroundImage
            })

        imageContext.render(composedImage, to: pixelBuffer)
        request.finish(withComposedVideoFrame: pixelBuffer)
    }
}
