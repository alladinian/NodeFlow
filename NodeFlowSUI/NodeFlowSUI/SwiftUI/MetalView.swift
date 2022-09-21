//
//  MetalView.swift
//  Iconic
//
//  Created by Vasilis Akoinoglou on 27/4/21.
//

import MetalKit
import SwiftUI
import AVFoundation

struct MetalView: NSViewRepresentable {

    let image: CIImage?

    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> CIMetalView {
        let view = CIMetalView()
        view.image = image
        return view
    }

    func updateNSView(_ view: CIMetalView, context: NSViewRepresentableContext<MetalView>) {
        view.image = image
    }
}

class CIMetalView: MTKView {

    var image: CIImage? {
        didSet {
            self.draw()
        }
    }

    var commandQueue: MTLCommandQueue!

    convenience init(frame: CGRect) {
        let device = MTLCreateSystemDefaultDevice()
        self.init(frame: frame, device: device)
    }

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        guard let device = device else {
            fatalError("Can't use Metal")
        }

        commandQueue = device.makeCommandQueue(maxCommandBufferCount: 5)!

        super.init(frame: frameRect, device: device)

        layer?.isOpaque          = false
        preferredFramesPerSecond = 60
        enableSetNeedsDisplay    = true
        isPaused                 = true
        framebufferOnly          = false
        clearColor               = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        drawableSize             = frame.size
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCommandEncoder(_ commandBuffer: MTLCommandBuffer) {
        guard let rpd = currentRenderPassDescriptor else { return }

        rpd.colorAttachments[0].clearColor  = MTLClearColorMake(1, 0, 0, 0)
        rpd.colorAttachments[0].loadAction  = .clear
        rpd.colorAttachments[0].storeAction = .store
        let re = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)
        re?.endEncoding()
    }

    override func draw(_ rect: CGRect) {

        // See: https://stackoverflow.com/questions/55769612/mtkview-drawing-performance
        
        let context = CIContext(mtlDevice: device!)

        guard let drawable = currentDrawable, let commandBuffer = commandQueue.makeCommandBuffer(), let image = image else { return }

        guard drawableSize.width != 0, drawableSize.height != 0 else { return }

        setupCommandEncoder(commandBuffer)

        // Scale the image to fit the view
        var bounds         = bounds
        bounds.size        = drawableSize
        bounds             = AVMakeRect(aspectRatio: image.extent.size, insideRect: bounds)

        let scaleTransform = CGAffineTransform(scaleX: bounds.size.width / image.extent.width, y: bounds.size.height / image.extent.height)
        let scaledImage    = image.transformed(by: scaleTransform)

        // Center in the view
        let originX       = max(drawableSize.width - scaledImage.extent.width, 0) / 2
        let originY       = max(drawableSize.height - scaledImage.extent.height, 0) / 2
        let centeredImage = scaledImage.transformed(by: CGAffineTransform(translationX: originX, y: originY))
//        let x                 = -bounds.origin.x
//        let y                 = -bounds.origin.y
//        let destinationBounds = CGRect(origin: CGPoint(x: x, y: y), size: drawableSize)

        // Render
//        kImageProcessorContext.render(scaledImage,
//                                      to: drawable.texture,
//                                      commandBuffer: commandBuffer,
//                                      bounds: destinationBounds,
//                                      colorSpace: CGColorSpaceCreateDeviceRGB())

        // create a render destination that allows to lazily fetch the target texture
        // which allows the encoder to process all CI commands _before_ the texture is actually available;
        // this gives a nice speed boost because the CPU doesn’t need to wait for the GPU to finish
        // before starting to encode the next frame
        let destination = CIRenderDestination(width: Int(drawableSize.width),
                                              height: Int(drawableSize.height),
                                              pixelFormat: colorPixelFormat,
                                              commandBuffer: commandBuffer,
                                              mtlTextureProvider: {  drawable.texture })

        let _ = try! context.startTask(toRender: centeredImage, to: destination)
        // bonus: you can Quick Look the task to see what’s actually scheduled for the GPU

        // optional: you can wait for the task execution and Quick Look the info object to get insights and metrics
        /*
        DispatchQueue.global(qos: .background).async {
            let info = try! task.waitUntilCompleted()
        }
         */

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
