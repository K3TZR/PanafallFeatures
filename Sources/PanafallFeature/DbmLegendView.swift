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

struct DbmLegendView: View {
  var viewStore: ViewStore<PanafallFeature.State, PanafallFeature.Action>
  @ObservedObject var panadapter: Panadapter
  let spacing: CGFloat
  let width: CGFloat
  let height: CGFloat
  let color: Color
  
  var pixelPerDbm: CGFloat { height / (panadapter.maxDbm - panadapter.minDbm) }
  var offset: CGFloat { panadapter.maxDbm.truncatingRemainder(dividingBy: spacing) }
  
  @State var startDbm: CGFloat?
  
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
        .frame(width: 40).border(.red)
        .foregroundColor(.white).opacity(0.1)
        .gesture(
          DragGesture()
            .onChanged {value in
              let isUpper = value.startLocation.y < height/2
              if let startDbm {
                let intNewDbm = Int(startDbm + value.translation.height/pixelPerDbm)
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
        .contextMenu {
          Button {  } label: {Text("5 dbm")}
          Button {  } label: {Text("10 dbm")}
          Button {  } label: {Text("15 dbm")}
          Button {  } label: {Text("20 dbm")}
        }
    }
  }
}

//struct DbmLegendView_Previews: PreviewProvider {
//  static var previews: some View {
//    DbmLegendView(viewStore: ,
//                  high: 10,
//                  low: -100,
//                  spacing: .constant(10),
//                  width: 800,
//                  height: 600,
//                  color: .white)
//  }
//}
