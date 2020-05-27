import AVKit
import SceneKit

public protocol RenderPipelineVideoOutput {
    func render(image: CIImage, context: CIContext, pipeline: RenderPipeline)
}

public protocol RenderPipelineListener {
    func renderPipelineDidChangeFilters(_ renderPipeline: RenderPipeline)
}

public class RenderPipeline: NSObject {
    static let shareGroup: EAGLSharegroup = {
        return EAGLSharegroup()
    }()

    var pixelBufferPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange

    public let imageContext: CIContext
    public let device = MTLCreateSystemDefaultDevice()

    public init(size: CGSize) {
        self.size = size
        self.imageContext = CIContext(mtlDevice: device!)
    }

    public lazy var commandQueue: MTLCommandQueue? = {
        return device?.makeCommandQueue()
    }()

    public var size: CGSize {
        didSet {
            if size != oldValue {
                cachedScaledOverlay = nil
            }
        }
    }

    // MARK: - Overlay

    public var overlay: UIImage? {
        didSet {
            if overlay != oldValue {
                cachedScaledOverlay = nil
            }
        }
    }

    private var cachedScaledOverlay: CIImage?

    var scaledOverlay: CIImage? {
        if let cachedScaledOverlay = cachedScaledOverlay {
            return cachedScaledOverlay
        }

        guard let overlay = overlay?.cgImage else {
            return nil
        }

        let fullSizeRect = CGRect(origin: CGPoint.zero, size: size)

        let overlayCIImage = CIImage(cgImage: overlay)
        let overlayScaleTransform = CGAffineTransform.aspectFill(from: overlayCIImage.extent, to: fullSizeRect)
        let scaledOverlay = overlayCIImage.transformed(by: overlayScaleTransform)
        self.cachedScaledOverlay = scaledOverlay
        return scaledOverlay
    }

    // MARK: - Pipeline

    public var filters = [CIFilter]()

    public var orientationTransform = CGAffineTransform.identity

    public var mirrorVideo = false

    func rendererdImage(image: CIImage) -> CIImage {
        let transformedImage = image.applying(orientationTransform: orientationTransform, mirrored: mirrorVideo)

        let filteredImage = self.filters.reduce(transformedImage) { (lastImage, filter) -> CIImage in
            filter.setValue(lastImage, forKey: kCIInputImageKey)
            guard let outputImage = filter.outputImage else {
                assertionFailure()
                return lastImage
            }
            return outputImage
        }

//        assert(filteredImage.extent.size == self.size)

        return filteredImage
    }

    public func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer {
        guard filters.count > 0 else {
            return sampleBuffer
        }

        assertionFailure("Can't filter sample buffers yet")
        return sampleBuffer
    }

    public func process(image: UIImage) throws -> UIImage {
        guard let inputImage = CIImage(image: image) else {
            throw NSError(domain: "com.outtherelabs.videopipelinekit", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not process image"])
        }

        let renderedImage = self.rendererdImage(image: inputImage)

        return UIImage(ciImage: renderedImage)
    }

    public func render(uiImage image: UIImage) throws {
        guard let inputImage = CIImage(image: image) else {
            throw NSError(domain: "com.outtherelabs.videopipelinekit", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not process image"])
        }

        render(ciImage: inputImage)
    }

    let renderSemaphore = DispatchSemaphore(value: 1)

    public func render(ciImage image: CIImage) {
        if renderSemaphore.wait(timeout: DispatchTime.now()) == .timedOut {
            return
        }

        defer {
            renderSemaphore.signal()
        }

        let preferredSize = CGRect(origin: CGPoint.zero, size: size)
        let scaleTransform = CGAffineTransform.aspectFill(from: image.extent, to: preferredSize)
        let scaledImage = image.transformed(by: scaleTransform)

        var renderedImage = rendererdImage(image: scaledImage)

        if let scaledOverlay = scaledOverlay {
            renderedImage = scaledOverlay.composited(over: renderedImage)
        }

        forwardToOutputs(image: renderedImage)
    }

    public func render(image: CIImage, to pixelBuffer: CVPixelBuffer) {
        let renderedImage = rendererdImage(image: image)
        imageContext.render(renderedImage, to: pixelBuffer)
    }

    func forwardToOutputs(image: CIImage) {
        for videoOutput in videoOutputs {
            videoOutput.render(image: image, context: imageContext, pipeline: self)
        }
    }

    // MARK: Output

    var videoOutputs = [RenderPipelineVideoOutput]()

    public func add(videoOutput: RenderPipelineVideoOutput) {
        videoOutputs.append(videoOutput)
    }
}

extension CIImage {
    func applying(orientationTransform: CGAffineTransform?, mirrored: Bool) -> CIImage {
        var result = self

        if let transform = orientationTransform {
            result = result.transformed(by: transform)
        }

        if mirrored {
            let transform = CGAffineTransform(scaleX: -1, y: 1)
            result = result.transformed(by: transform)
        }

        let originTransform = CGAffineTransform(translationX: -result.extent.origin.x, y: -result.extent.origin.y)
        result = result.transformed(by: originTransform)

        return result
    }
}

extension CGAffineTransform {
    static func aspectFill(from: CGRect, to: CGRect) -> CGAffineTransform {
        if from.size == to.size {
            return CGAffineTransform.identity
        }

        let horizontalRatio = to.width / from .width
        let verticalRatio = to.height / from.height
        let scale = max(horizontalRatio, verticalRatio)
        let translationX = horizontalRatio < verticalRatio ? (to.width - from.width * scale) * 0.5 : 0
        let translationY = horizontalRatio > verticalRatio ? (to.height - from.height * scale) * 0.5 : 0
        return CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: translationX, y: translationY)
    }
}

import MetalKit

extension MTKView: RenderPipelineVideoOutput {
    public func render(image: CIImage, context: CIContext, pipeline: RenderPipeline) {
        guard let commandQueue = pipeline.commandQueue else { return }

        autoreleasepool {
            guard let currentDrawable = currentDrawable else {
                return
            }

            #if arch(i386) || arch(x86_64)
                assertionFailure("Can't use MTKView as a render pipeline output on a Simulator, it doesn't support metal.")
            #else
                guard let commandBuffer = commandQueue.makeCommandBuffer() else {
                    return
                }
                let renderedImageRect = CGRect(origin: CGPoint.zero, size: image.extent.size)
                let destinationRect = CGRect(origin: CGPoint.zero, size: drawableSize)
                let scaledImage = image.transformed(by: CGAffineTransform.aspectFill(from: renderedImageRect, to: destinationRect))
                context.render(scaledImage, to: currentDrawable.texture, commandBuffer: commandBuffer, bounds: scaledImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
                commandBuffer.present(currentDrawable)
                commandBuffer.commit()
            #endif
        }
    }
}
