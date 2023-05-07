//
//  DbmLinesView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

struct DbmLinesView: View {
//  let store: StoreOf<PanFeature>
  @ObservedObject var panadapter: Panadapter
//  let high: CGFloat
//  let low: CGFloat
  let spacing: CGFloat
  let width: CGFloat
  let height: CGFloat
  let color: Color

  var pixelPerDbm: CGFloat { height / (panadapter.maxDbm - panadapter.minDbm) }
  var offset: CGFloat { panadapter.maxDbm.truncatingRemainder(dividingBy: spacing) }

  var body: some View {
    Path { path in
      var y: CGFloat = offset * pixelPerDbm
      repeat {
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: width, y: y))
        y += pixelPerDbm * spacing
      } while y < height
    }
    .stroke(color, lineWidth: 1)
  }
}

struct DbmLinesView_Previews: PreviewProvider {
    static var previews: some View {
      DbmLinesView(panadapter: Panadapter(0x49999999),
//                   high: 10,
//                   low: -100,
                   spacing: 10,
                   width: 800,
                   height: 600,
                   color: .gray)
    }
}
