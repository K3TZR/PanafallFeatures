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
  var viewStore: ViewStore<PanadapterFeature.State, PanadapterFeature.Action>
  @ObservedObject var panadapter: Panadapter
  let spacings: [(Int,Int)]
  
  @State var startCenter: CGFloat?
  @State var rightMouseDownLocation: NSPoint = .zero
  
  @AppStorage("gridlines") var color: Color = .white.opacity(0.3)
  
  private var spacing: CGFloat {
    for spacing in spacings {
      if panadapter.bandwidth >= spacing.0 { return CGFloat(spacing.1) }
    }
    return CGFloat(spacings[0].1)
  }
  
  private func initialXPosition(_ width: CGFloat) -> CGFloat {
    -CGFloat(panadapter.center - panadapter.bandwidth/2).truncatingRemainder(dividingBy: spacing) * pixelPerHz(width)
  }
  
  private func pixelPerHz(_ width: CGFloat) -> CGFloat {
    width / CGFloat(panadapter.bandwidth)
  }
  
  private func clickFrequency(_ width: CGFloat) -> Int {
    Int( CGFloat(panadapter.center - panadapter.bandwidth/2) + CGFloat(panadapter.bandwidth) * (rightMouseDownLocation.x / width) )
  }
  
  var body: some View {
    GeometryReader { g in
      Path { path in
        var xPosition: CGFloat = initialXPosition(g.size.width)
        repeat {
          path.move(to: CGPoint(x: xPosition, y: 0))
          path.addLine(to: CGPoint(x: xPosition, y: g.size.height))
          xPosition += pixelPerHz(g.size.width) * spacing
        } while xPosition < g.size.width
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
              if abs(value.translation.width) > pixelPerHz(g.size.width) {
                let newCenter = Int(startCenter - (value.translation.width / pixelPerHz(g.size.width) ))
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
        Button("Create Slice") { viewStore.send(.sliceCreate(panadapter, clickFrequency(g.size.width))) }
        Button("Create Tnf") { viewStore.send(.tnfCreate( clickFrequency(g.size.width))) }
      }
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
    FrequencyLinesView(viewStore: ViewStore(Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature())),
                       panadapter: pan,
                       //                       width: 800,
                       //                       height: 600,
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
