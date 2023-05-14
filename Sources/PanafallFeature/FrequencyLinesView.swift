//
//  FrequencyLinesView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

struct FrequencyLinesView: View {
  var viewStore: ViewStore<PanafallFeature.State, PanafallFeature.Action>
  @ObservedObject var panadapter: Panadapter
  let params: (spacing: CGFloat, format: String)
  let width: CGFloat
  let height: CGFloat
  let color: Color

  var low: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var high: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var pixelPerHz: CGFloat { width / CGFloat(high - low) }

  // left-drag
  var drag: some Gesture {
    DragGesture(minimumDistance: pixelPerHz)
      .onChanged { value in
//        print("Frequency lines drag")
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
//        print("Frequency lines drag END")
        startCenter = nil
      }
  }

  @State var startCenter: CGFloat?
  @State var rightMouseDownLocation: NSPoint = .zero
  
  var bw: CGFloat { CGFloat(panadapter.bandwidth) }
  var clickFrequency: Int { Int(low + bw * (rightMouseDownLocation.x/width)) }

  var body: some View {
    Path { path in
      var xPosition: CGFloat = (-low.truncatingRemainder(dividingBy: params.spacing)) * pixelPerHz
      repeat {
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: height))
        xPosition += pixelPerHz * params.spacing
      } while xPosition < width
    }
    .stroke(color, lineWidth: 1)
    .contentShape(Rectangle())

    .onAppear(perform: {
      NSEvent.addLocalMonitorForEvents(matching: [.rightMouseDown]) {
        rightMouseDownLocation = $0.locationInWindow
        return $0
      }
    })

    .gesture(drag)
    
    .contextMenu {
      Button("Create Slice") { viewStore.send(.sliceCreate(clickFrequency)) }
      Button("Create Tnf") { viewStore.send(.tnfCreate(clickFrequency)) }
    }
  }
}


//struct FrequencyLinesView_Previews: PreviewProvider {
//    static var previews: some View {
//      FrequencyLinesView(viewStore: ,
//                         panadapter: Panadapter(0x49999999),
//                         spacing: 20_000,
//                         width: 800,
//                         height: 600,
//                         color: .white)
//    }
//}
