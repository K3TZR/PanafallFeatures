//
//  Renderer.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

//import MetalKit
//
//public class Renderer: NSObject, MTKViewDelegate {
//
//  private struct Vertex {
//    var position: simd_float2
//    var color: simd_float4
//  }
//
//  var parent: PanView
//  var metalDevice: MTLDevice!
//  var metalCommandQueue: MTLCommandQueue!
//  let pipelineState: MTLRenderPipelineState
//  let vertexBuffer: MTLBuffer
//
//  init(_ parent: PanView) {
//
//    self.parent = parent
//    if let metalDevice = MTLCreateSystemDefaultDevice() {
//      self.metalDevice = metalDevice
//    }
//    self.metalCommandQueue = metalDevice.makeCommandQueue()
//
//    let pipelineDescriptor = MTLRenderPipelineDescriptor()
//    let library = try! metalDevice.makeDefaultLibrary(bundle: Bundle.module)
//    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
//    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
//    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//
//    do {
//      try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
//    } catch {
//      fatalError()
//    }
//
//
//    let vertices = [
//      Vertex(position: [-1, -1], color: [1, 0, 0, 1]),
//      Vertex(position: [1, -1], color: [0, 1, 0, 1]),
//      Vertex(position: [0, 1], color: [0, 0, 1, 1])
//    ]
//    vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
//    super.init()
//  }
//
//  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//
//  }
//
//  public func draw(in view: MTKView) {
//
//    guard let drawable = view.currentDrawable else {
//      return
//    }
//
//    let commandBuffer = metalCommandQueue.makeCommandBuffer()
//
//    let renderPassDescriptor = view.currentRenderPassDescriptor
//    renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
//    renderPassDescriptor?.colorAttachments[0].loadAction = .clear
//    renderPassDescriptor?.colorAttachments[0].storeAction = .store
//
//    let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
//
//    renderEncoder?.setRenderPipelineState(pipelineState)
//    renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//    renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
//
//    renderEncoder?.endEncoding()
//
//    commandBuffer?.present(drawable)
//    commandBuffer?.commit()
//  }
//}

//
//  PanRenderer.swift
//  ViewFeatures/PanFeature
//
//  Created by Douglas Adams on 9/30/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation
import MetalKit
import SwiftUI

import FlexApi
import Shared

public final class PanRenderer: NSObject {
  //  As input, the renderer expects an array of UInt16 intensity values. The intensity values are
  //  scaled by the radio to be between zero and Panadapter.yPixels. The values are inverted
  //  i.e. the value of Panadapter.yPixels is zero intensity and a value of zero is maximum intensity.
  //  The Panadapter sends an array of size Panadapter.xPixels (same as frame.width).

  init(_ panStream: PanadapterStream) {
    self.panStream = panStream
    
    super.init()
    setup()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kMaxIntensities = 3_072  // max number of intensity values (bins)
  
  // ----------------------------------------------------------------------------
  // MARK: - Shader structs
  
  private struct SpectrumValue {
    var i: ushort                     // intensity
  }
  
  private struct Constants {
    var delta: Float = 0              // distance between x coordinates
    var height: Float = 0             // height of view (yPixels)
    var maxNumberOfBins: UInt32 = 0   // number of DataFrame bins
  }
  
  private struct Color {
    var spectrumColor: SIMD4<Float>   // spectrum / fill color
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  @ObservedObject var panStream: PanadapterStream

  private var _metalView: MTKView!
  private var _metalDevice: MTLDevice!
  
  private var _spectrumValues = [UInt16](repeating: 0, count: PanRenderer.kMaxIntensities * 2)
  private var _spectrumBuffers = [MTLBuffer]()
  private var _spectrumIndices = [UInt16](repeating: 0, count: PanRenderer.kMaxIntensities * 2)
  private var _spectrumIndicesBuffer: MTLBuffer!
  
  private var _maxNumberOfBins = PanRenderer.kMaxIntensities
  
  private var _colorArray = [Color](repeating: Color(spectrumColor: NSColor.yellow.float4Color), count: 2)
  
  private var _commandQueue: MTLCommandQueue!
  private var _pipelineState: MTLRenderPipelineState!
    
  private let _panQ = DispatchQueue(label: "Api6000.panQ", attributes: [.concurrent])
  private var _isDrawing: DispatchSemaphore = DispatchSemaphore(value: 1)
  
  // ----- Backing properties - SHOULD NOT BE ACCESSED DIRECTLY -----------------------------------
  //
  private var __constants = Constants()
  private var __currentFrameIndex = 0
  private var __numberOfBins = UInt32(PanRenderer.kMaxIntensities)
  //
  // ----- Backing properties - SHOULD NOT BE ACCESSED DIRECTLY -----------------------------------
  
  private var _constants: Constants {
    get { return _panQ.sync { __constants } }
    set { _panQ.sync( flags: .barrier) { __constants = newValue } } }
  
  private var _currentFrameIndex: Int {
    get { return _panQ.sync { __currentFrameIndex } }
    set { _panQ.sync( flags: .barrier) { __currentFrameIndex = newValue } } }
  
  private var _numberOfBins: UInt32 {
    get { return _panQ.sync { __numberOfBins } }
    set { _panQ.sync( flags: .barrier) { __numberOfBins = newValue } } }
    
  // ----------------------------------------------------------------------------
  // MARK: - Internal methods
  
  func setConstants(size: CGSize) {
//    self._isDrawing.wait()
    
    // Constants struct mapping (bytes)
    //  <--- 4 ---> <--- 4 ---> <--- 4 ---> <-- empty -->              delta, height, maxNumberOfBins
    
    // populate it
    _constants.delta = Float(1.0 / (size.width - 1.0))
    _constants.height = Float(size.height)
    _constants.maxNumberOfBins = UInt32(_maxNumberOfBins)
    
//    self._isDrawing.signal()
  }
  
  func updateColor(spectrumColor: NSColor, fillLevel: Int, fillColor: NSColor) {
//    self._isDrawing.wait()
    
    // Color struct mapping
    //  <--------------------- 16 ---------------------->              spectrumColor
    
    // calculate the effective fill color
    let fillPercent = CGFloat(fillLevel)/CGFloat(100.0)
    let adjFillColor = NSColor(red: fillColor.redComponent * fillPercent,
                               green: fillColor.greenComponent * fillPercent,
                               blue: fillColor.blueComponent * fillPercent,
                               alpha: fillColor.alphaComponent * fillPercent)

    // update the array (0 = fill, 1 = spectrum)
    _colorArray[0].spectrumColor = adjFillColor.float4Color
    _colorArray[1].spectrumColor = spectrumColor.float4Color

//    self._isDrawing.signal()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Setup Objects, Buffers & State
  ///
  func setup() {
    if let metalDevice = MTLCreateSystemDefaultDevice() {
      _metalDevice = metalDevice
    }

    setConstants(size: CGSize(width: 600, height: 300))
    updateColor(spectrumColor: NSColor.white.usingColorSpace(.sRGB)!, fillLevel: 20, fillColor: NSColor.yellow.usingColorSpace(.sRGB)!)

    // create and populate Spectrum buffers
    let dataSize = _spectrumValues.count * MemoryLayout.stride(ofValue: _spectrumValues[0])
    for _ in 0..<3 {
      _spectrumBuffers.append(_metalDevice.makeBuffer(bytes: _spectrumValues, length: dataSize, options: [.storageModeShared])!)
    }
    
    // populate the Indices array used for style == .fill || style == .fillWithTexture
    for i in 0..<PanRenderer.kMaxIntensities {
      // n,0,n+1,1,...2n-1,n-1
      _spectrumIndices[2 * i] = UInt16(PanRenderer.kMaxIntensities + i)
      _spectrumIndices[(2 * i) + 1] = UInt16(i)
    }
    
    // create and populate an Indices buffer (for filled drawing only)
    let indexSize = _spectrumIndices.count * MemoryLayout.stride(ofValue: _spectrumIndices[0])
    _spectrumIndicesBuffer = _metalDevice.makeBuffer(bytes: _spectrumIndices, length: indexSize, options: [.storageModeShared])
    
    // get the Shaders library
    let library = try! _metalDevice.makeDefaultLibrary(bundle: Bundle.module)
    
    // create a Render Pipeline descriptor
    let rpd = MTLRenderPipelineDescriptor()
    rpd.vertexFunction = library.makeFunction(name: "panadapter_vertex")
    rpd.fragmentFunction = library.makeFunction(name: "panadapter_fragment")
    rpd.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    // create the Render Pipeline State object
    do {
      _pipelineState = try _metalDevice.makeRenderPipelineState(descriptor: rpd)
    } catch {
      fatalError("PanadapterRenderer: failed to create render pipeline")
    }
    
    // create and save a Command Queue object
    _commandQueue = _metalDevice.makeCommandQueue()
    _commandQueue.label = "Panadapter"
  }
}

// ----------------------------------------------------------------------------
// MARK: - MTKViewDelegate protocol methods

extension PanRenderer: MTKViewDelegate {
  
  /// Respond to a change in the size of the MTKView
  /// - Parameters:
  ///   - view:             the MTKView
  ///   - size:             its new size
  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    // not used
  }
  /// Draw in the MTKView
  /// - Parameter view:     the MTKView
  public func draw(in view: MTKView) {
    
//    self._isDrawing.wait()
    
    guard let drawable = view.currentDrawable else {
      return
    }

    // obtain a Command buffer & a Render Pass descriptor
    guard let cmdBuffer = self._commandQueue.makeCommandBuffer(),
          let descriptor = view.currentRenderPassDescriptor else { return }
    
    descriptor.colorAttachments[0].loadAction = .clear
    descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1.0)
    //        descriptor.colorAttachments[0].storeAction = .dontCare   // causes an issue in M1 Macs
    
    // Create a render encoder
    let encoder = cmdBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
    
    encoder.pushDebugGroup("Fill")
    
    // set the Spectrum pipeline state
    encoder.setRenderPipelineState(_pipelineState)
    
    // bind the active Spectrum buffer
//    encoder.setVertexBuffer(_spectrumBuffers[_currentFrameIndex], offset: 0, index: 0)
//    // frameBinCount is the number of horizontal pixels in the spectrum waveform
//    _numberOfBins = UInt32(panStream.currentFrame.frameBinCount)
    
    // put the Intensities into the current Spectrum Buffer
    _spectrumBuffers[_currentFrameIndex].contents().copyMemory(from: panStream.currentFrame.bins, byteCount: panStream.currentFrame.frameBinCount * MemoryLayout<ushort>.stride)
    encoder.setVertexBuffer(_spectrumBuffers[_currentFrameIndex], offset: 0, index: 0)

//    print(panStream.currentFrame.frameNumber)
    
    
    // bind the Constants
    encoder.setVertexBytes(&_constants, length: MemoryLayout.size(ofValue: _constants), index: 1)
    
    //    // is the Panadapter "filled"?
    //    if self._fillLevel > 1 {
    
    // YES, bind the Fill Color
    encoder.setVertexBytes(&_colorArray[0], length: MemoryLayout.size(ofValue: _colorArray[0]), index: 2)
    
    // Draw filled
    encoder.drawIndexedPrimitives(type: .triangleStrip, indexCount: Int(_numberOfBins * 2), indexType: .uint16, indexBuffer: _spectrumIndicesBuffer, indexBufferOffset: 0)
    //    }
    encoder.popDebugGroup()
    encoder.pushDebugGroup("Line")
    
    // bind the Line Color
    encoder.setVertexBytes(&_colorArray[1], length: MemoryLayout.size(ofValue: _colorArray[1]), index: 2)
    
    // Draw as a Line
    encoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: Int(_numberOfBins))
    
    // finish using this encoder
    encoder.endEncoding()
    
    // present the drawable to the screen
    cmdBuffer.present(drawable)
    
    // push the command buffer to the GPU
    cmdBuffer.commit()
    
//    self._isDrawing.signal()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Panadapter StreamHandler

//extension PanRenderer: StreamHandler {
  
  //  DataFrame Layout: (see ApiFeatures/PanadapterStream/PanadapterFrame)
  //
  //  public var startingBinNumber = 0     // Index of first bin
  //  public var segmentBinCount = 0       // Number of bins
  //  public var binSize = 0               // Bin size in bytes
  //  public var frameBinCount = 0         // number of bins in the complete frame
  //  public var frameNumber = 0           // Frame number
  //  public var bins = [UInt16](repeating: 0, count: kMaxBins)         // Array of bin values
  
  /// Process the UDP Stream Data for the Panadapter
  /// - Parameter streamFrame:        a Panadapter frame
//  public func streamHandler<T>(_ streamFrame: T) {
//
//    guard let streamFrame = streamFrame as? PanadapterFrame else { return }
//
//    _isDrawing.wait()
//    // move to using the next spectrumBuffer
//    _currentFrameIndex = (_currentFrameIndex + 1) % 3
//
//    // frameBinCount is the number of horizontal pixels in the spectrum waveform
//    _numberOfBins = UInt32(streamFrame.frameBinCount)
//
//    // put the Intensities into the current Spectrum Buffer
//    _spectrumBuffers[_currentFrameIndex].contents().copyMemory(from: streamFrame.bins, byteCount: streamFrame.frameBinCount * MemoryLayout<ushort>.stride)
//
//    _isDrawing.signal()
//  }
//}
