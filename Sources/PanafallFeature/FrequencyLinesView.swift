//
//  FrequencyLinesView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import SwiftUI

import FlexApi

struct FrequencyLinesView: View {
  @ObservedObject var panadapter: Panadapter
  let spacing: CGFloat
  let width: CGFloat
  let height: CGFloat
  let color: Color

  var low: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var high: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var xOffset: CGFloat { -low.truncatingRemainder(dividingBy: spacing) }
  var pixelPerHz: CGFloat { width / CGFloat(high - low) }

  var body: some View {
    Path { path in
      var xPosition: CGFloat = xOffset * pixelPerHz
      repeat {
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: height))
        xPosition += pixelPerHz * spacing
      } while xPosition < width
    }
    .stroke(color, lineWidth: 1)
    .contentShape(Rectangle())

    .gesture(
      DragGesture()
        .onChanged { drag in
          print("Frequency lines drag")
//          if abs(drag.startLocation.x - drag.location.x) > abs(drag.startLocation.y - drag.location.y) {
//            if let start = startCenter {
//              DispatchQueue.main.async { center = start + ((drag.startLocation.x - drag.location.x)/pixelPerHz) }
//            } else {
//              startCenter = center
//            }
//          } else if abs(drag.startLocation.y - drag.location.y) > abs(drag.startLocation.x - drag.location.x) {
//            if let startHigh, let startLow {
//              DispatchQueue.main.async { [drag] in
//                dbmHigh = startHigh - ((drag.startLocation.y - drag.location.y)/pixelPerDbm)
//                dbmLow = startLow - ((drag.startLocation.y - drag.location.y)/pixelPerDbm)
//              }
//            } else {
//              startLow = dbmLow
//              startHigh = dbmHigh
//            }
//          } else {
//            print("NO drag")
//          }
          
        }
        .onEnded { _ in
          print("Frequency lines drag END")
//          startCenter = nil
//          startLow = nil
//          startHigh = nil
        }
      )
  }
}


struct FrequencyLinesView_Previews: PreviewProvider {
    static var previews: some View {
      FrequencyLinesView(panadapter: Panadapter(0x49999999),
                         spacing: 20_000,
                         width: 800,
                         height: 600,
                         color: .white)
    }
}
