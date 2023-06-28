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

// ----------------------------------------------------------------------------
// MARK: - View

struct DbmLinesView: View {
  @ObservedObject var panadapter: Panadapter
  let size: CGSize
  let frequencyLegendHeight: CGFloat
  
  @AppStorage("dblinesColor") var dblinesColor = DefaultColors.dbLinesColor
  @AppStorage("dbSpacing") var dbSpacing: Int = 10

  var pixelPerDbm: CGFloat { (size.height  - frequencyLegendHeight) / (panadapter.maxDbm - panadapter.minDbm) }
  var yOffset: CGFloat { panadapter.maxDbm.truncatingRemainder(dividingBy: CGFloat(dbSpacing)) }

  var body: some View {
    Path { path in
      var yPosition: CGFloat = yOffset * pixelPerDbm
      repeat {
        path.move(to: CGPoint(x: 0, y: yPosition))
        path.addLine(to: CGPoint(x: size.width, y: yPosition))
        yPosition += (pixelPerDbm * CGFloat(dbSpacing))
      } while yPosition < size.height - frequencyLegendHeight
    }
    .stroke(dblinesColor, lineWidth: 1)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct DbmLinesView_Previews: PreviewProvider {

  static var pan: Panadapter {
    let p = Panadapter(0x49999999)
    p.center = 14_100_000
    p.bandwidth = 200_000
    p.maxDbm = 10
    p.minDbm = -120
    return p
  }

  static var previews: some View {
    DbmLinesView(panadapter: pan, size: CGSize(width: 900, height: 450), frequencyLegendHeight: 20)
      .frame(width: 900, height: 450)
    }
}
