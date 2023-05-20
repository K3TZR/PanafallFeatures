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
  let spacing: CGFloat
  let width: CGFloat
  let height: CGFloat
  
  var pixelPerDbm: CGFloat { height / (panadapter.maxDbm - panadapter.minDbm) }
  var offset: CGFloat { panadapter.maxDbm.truncatingRemainder(dividingBy: spacing) }
  
  @State var startDbm: CGFloat?

  @AppStorage("dbmLegend") var color: Color = .green

  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentDbm = panadapter.maxDbm
    repeat {
      array.append( currentDbm )
      currentDbm -= spacing
    } while ( currentDbm >= panadapter.minDbm )
    return array
  }
  
  var body: some View {
    
    ZStack(alignment: .trailing) {
      ForEach(Array(legends.enumerated()), id: \.offset) { i, value in
        if value > panadapter.minDbm {
          Text(String(format: "%0.0f", value - offset))
            .position(x: width - 20, y: (offset + CGFloat(i) * spacing) * pixelPerDbm)
            .foregroundColor(color)
        }
      }
      
      Rectangle()
        .frame(width: 40)
        .foregroundColor(.white).opacity(0.1)
        .gesture(
          DragGesture()
            .onChanged {value in
              let isUpper = value.startLocation.y < height/2
              if let startDbm {
                let intNewDbm = Int(startDbm + (value.translation.height/pixelPerDbm))
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
      Button("5 dbm") { viewStore.send(.dbLegendSpacing(5)) }
      Button("10 dbm") { viewStore.send(.dbLegendSpacing( 10)) }
      Button("15 dbm") { viewStore.send(.dbLegendSpacing( 15)) }
      Button("20 dbm") { viewStore.send(.dbLegendSpacing( 20)) }
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
                  panadapter: pan,
                  spacing: 10,
                  width: 800,
                  height: 600)
    .frame(width:800, height: 600)
  }
}
