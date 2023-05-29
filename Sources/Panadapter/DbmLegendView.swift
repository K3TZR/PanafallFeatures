//
//  DbmLegendView.swift
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

struct DbmLegendView: View {
  var viewStore: ViewStore<PanadapterFeature.State, PanadapterFeature.Action>
  @ObservedObject var panadapter: Panadapter
  let size: CGSize
  
  @State var startDbm: CGFloat?
  
  @AppStorage("dbmLegend") var dbmLegendColor: Color = .green
  @AppStorage("dbmSpacing") var dbmSpacing: Int = 10
  
  var offset: CGFloat { panadapter.maxDbm.truncatingRemainder(dividingBy: CGFloat(dbmSpacing)) }
  
  private func pixelPerDbm(_ height: CGFloat) -> CGFloat {
    height / (panadapter.maxDbm - panadapter.minDbm)
  }
  
  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentDbm = panadapter.maxDbm
    repeat {
      array.append( currentDbm )
      currentDbm -= CGFloat(dbmSpacing)
    } while ( currentDbm >= panadapter.minDbm )
    return array
  }
  
  var body: some View {
    ZStack(alignment: .trailing) {
      ForEach(Array(legends.enumerated()), id: \.offset) { i, value in
        if value > panadapter.minDbm {
          Text(String(format: "%0.0f", value - offset))
            .position(x: size.width - 20, y: (offset + CGFloat(i) * CGFloat(dbmSpacing)) * pixelPerDbm(size.height))
            .foregroundColor(dbmLegendColor)
        }
      }
      
      Rectangle()
        .frame(width: 40)
        .foregroundColor(.white).opacity(0.1)
        .gesture(
          DragGesture()
            .onChanged {value in
              let isUpper = value.startLocation.y < size.height/2
              if let startDbm {
                let intNewDbm = Int(startDbm + (value.translation.height / pixelPerDbm(size.height)))
                if intNewDbm != Int(isUpper ? panadapter.maxDbm : panadapter.minDbm) {
                  viewStore.send(.dbLegendDrag(panadapter, isUpper, intNewDbm))
                }
              } else {
                startDbm = isUpper ? panadapter.maxDbm : panadapter.minDbm
              }
            }
            .onEnded { _ in
              startDbm = nil
            }
        )
    }
    .contextMenu {
      Button("5 dbm") { dbmSpacing = 5 }
      Button("10 dbm") { dbmSpacing = 10 }
      Button("15 dbm") { dbmSpacing = 15 }
      Button("20 dbm") { dbmSpacing = 20 }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct DbmLegendView_Previews: PreviewProvider {
  
  static var pan: Panadapter {
    let p = Panadapter(0x49999999)
    p.center = 14_100_000
    p.bandwidth = 200_000
    p.maxDbm = 10.0
    p.minDbm = -120.0
    return p
  }
  
  static var previews: some View {
    DbmLegendView(viewStore: ViewStore(Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature())),
                  panadapter: pan, size: CGSize(width: 900, height: 450))
    .frame(width:900, height: 450)
  }
}
