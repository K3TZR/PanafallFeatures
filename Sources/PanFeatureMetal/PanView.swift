//
//  PanadapterView.swift
//  
//
//  Created by Douglas Adams on 3/2/23.
//

import ComposableArchitecture
import MetalKit
import SwiftUI

import FlexApi
import Shared

public struct PanView: View {
  
  public init() {}
  
  @Dependency(\.objectModel) var objectModel

  public var body: some View {
    
    ZStack {
      GeometryReader { g in
        ForEach(objectModel.panadapters) { pan in
          
          VStack {
            HStack {
              MetalView(pan: pan)
              //        DbmLegendView(panId: panId)
            }
            FrequencyLegendView(pan: pan, width: g.size.width)
          }
        }
      }
    }
  }
}

private struct MetalView: NSViewRepresentable {
  let pan: Panadapter

  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel
  
  public typealias NSViewType = MTKView
  
  public func makeCoordinator() -> PanRenderer {
    PanRenderer(streamModel.panadapterStreams[id: pan.id]!)
  }
  
  public func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
    
    let mtkView = MTKView()
    mtkView.delegate = context.coordinator
    mtkView.preferredFramesPerSecond = 60
    mtkView.enableSetNeedsDisplay = true
    mtkView.isPaused = false

    if let metalDevice = MTLCreateSystemDefaultDevice() {
      mtkView.device = metalDevice
    }
    
    mtkView.framebufferOnly = false
    mtkView.frame.size = CGSize(width: 600, height: 300)
    mtkView.drawableSize = mtkView.frame.size

    pan.setProperty(.xpixels, String(Int(mtkView.frame.size.width)))
    pan.setProperty(.ypixels, String(Int(mtkView.frame.size.height)))
    return mtkView
  }
  
  public func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {
  }
}

private struct DbmLegendView: View {
  let panId: StreamId
  
  @Dependency(\.objectModel) var objectModel

  public var body: some View {
    VStack {
      Text(String(format: "%3.0f", objectModel.panadapters[id: panId]!.maxDbm))
      Spacer()
      Text(String(format: "%3.0f", objectModel.panadapters[id: panId]!.minDbm))
    }
  }
}

//private struct FrequencyLegendView: View {
//  let panId: StreamId
//  
//  @Dependency(\.objectModel) var objectModel
//
//  public var body: some View {
//    HStack {
//      Text((objectModel.panadapters[id: panId]!.center - objectModel.panadapters[id: panId]!.bandwidth/2).hzToMhz)
//      Spacer()
//      Text((objectModel.panadapters[id: panId]!.center + objectModel.panadapters[id: panId]!.bandwidth/2).hzToMhz)
//    }
//  }
//}

struct FrequencyLegendView: View {
  @ObservedObject var pan: Panadapter
  var width: CGFloat
  
  var body: some View {
    // Frequency legends
    
    let labelWidth: CGFloat = 50
    let spacing = ((width + labelWidth) - (CGFloat(pan.freqLegends.count) * labelWidth)) / CGFloat(pan.freqLegends.count)

    HStack(spacing: spacing) {
      ForEach(pan.freqLegends, id: \.id) { legend in
//        Text(legend.value).offset(x: (CGFloat(legend.id) * incr) - 10, y: height - legendHeight)
        if legend.id < 19 {
          Text(legend.value).border(.red)
        }
      }
    }
//  .offset(x: offset, y: 0)
  }
}

struct Paniew_Previews: PreviewProvider {
  static var previews: some View {
    PanView()
  }
}
