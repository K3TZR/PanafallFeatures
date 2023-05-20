//
//  FrequencyLinesView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct FrequencyLinesView: View {
  var viewStore: ViewStore<PanFeature.State, PanFeature.Action>
  @ObservedObject var panadapter: Panadapter
  let width: CGFloat
  let height: CGFloat
  let spacings: [(Int,Int)]
  
  var low: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var high: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var pixelPerHz: CGFloat { width / CGFloat(high - low) }
  
  @State var startCenter: CGFloat?
  @State var rightMouseDownLocation: NSPoint = .zero
  
  @AppStorage("gridlines") var color: Color = .white.opacity(0.3)
  
  var bw: CGFloat { CGFloat(panadapter.bandwidth) }
  var clickFrequency: Int { Int(low + bw * (rightMouseDownLocation.x/width)) }
  
  private var spacing: Int {
    for spacing in spacings {
      if panadapter.bandwidth >= spacing.0 { return spacing.1 }
    }
    return spacings[0].1
  }
  
  var body: some View {
    Path { path in
      var xPosition: CGFloat = (-low.truncatingRemainder(dividingBy: CGFloat(spacing)) * pixelPerHz)
      repeat {
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: height))
        xPosition += pixelPerHz * CGFloat(spacing)
      } while xPosition < width
    }
    .stroke(color, lineWidth: 1)
    .contentShape(Rectangle())
    
    // setup right mouse down tracking
    .onAppear(perform: {
      NSEvent.addLocalMonitorForEvents(matching: [.rightMouseDown]) {
        rightMouseDownLocation = $0.locationInWindow
        return $0
      }
    })
        
    // left-drag Panadapter center frequency
    .gesture(
      DragGesture()
        .onChanged { value in
          if let startCenter {
            if abs(value.translation.width) > pixelPerHz {
              let newCenter = Int(startCenter - (value.translation.width/pixelPerHz))
              viewStore.send(.frequencyLinesDrag(panadapter, newCenter))
            }
          } else {
            startCenter = CGFloat(panadapter.center)
          }
        }
        .onEnded { value in
          startCenter = nil
        }
    )
    
    .contextMenu {
      Button("Create Slice") { viewStore.send(.sliceCreate(panadapter, clickFrequency)) }
      Button("Create Tnf") { viewStore.send(.tnfCreate(clickFrequency)) }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct FrequencyLinesView_Previews: PreviewProvider {
  
  static var pan: Panadapter {
    let p = Panadapter(0x49999999)
    p.center = 14_100_000
    p.bandwidth = 200_000
    p.maxDbm = 10
    p.minDbm = -120
    return p
  }
  
  static var previews: some View {
    FrequencyLinesView(viewStore: ViewStore(Store(initialState: PanFeature.State(), reducer: PanFeature())),
                       panadapter: pan,
                       width: 800,
                       height: 600,
                       spacings: [
                        (10_000_000, 1_000_000),
                        (5_000_000, 500_000),
                        (1_000_000, 100_000),
                        (500_000, 50_000),
                        (400_000, 40_000),
                        (300_000, 30_000),
                        (200_000, 20_000),
                        (100_000, 10_000),
                        (50_000, 5_000),
                        (40_000, 4_000),
                        (30_000, 3_000),
                        (20_000, 2_000),
                        (10_000, 1_000)
                      ])
    .frame(width:800, height: 600)
  }
}
