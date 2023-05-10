//
//  FrequencyLegendView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

struct FrequencyLegendView: View {
  var viewStore: ViewStore<PanafallFeature.State, PanafallFeature.Action>
  @ObservedObject var panadapter: Panadapter
  let params: (spacing: CGFloat, format: String)
  let width: CGFloat
  let color: Color
  
  @State var startBandwidth: CGFloat?
  
  var low: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var high: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var xOffset: CGFloat { -low.truncatingRemainder(dividingBy: params.spacing) }
  var pixelPerHz: CGFloat { width / (high - low)}
  var legendWidth: CGFloat { pixelPerHz * params.spacing }
  var legendsOffset: CGFloat { xOffset * pixelPerHz }

  
  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentFrequency = low + xOffset
    repeat {
      array.append( currentFrequency )
      currentFrequency += params.spacing
    } while ( currentFrequency <= high )
    return array
  }
  
  var body: some View {
    HStack(spacing: 0) {
      ForEach(legends, id:\.self) { dbmValue in
        Text(String(format: params.format, dbmValue/1_000_000)).frame(width: legendWidth)
          .background(Color.white.opacity(0.1))
          .contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { value in
                print("Frequency Legend drag")
                if let startBandwidth {
                  let newBandwidth = Int(startBandwidth - (value.translation.width/pixelPerHz))
                    viewStore.send(.frequencyLegendDrag(panadapter, newBandwidth))
                } else {
                  startBandwidth = CGFloat(panadapter.bandwidth)
                }
              }
              .onEnded { _ in
                print("Frequency Legend drag END")
                startBandwidth = nil
              }
          )
          .offset(x: -legendWidth/2 )
          .foregroundColor(color)
          .contextMenu {
            Button { } label: {Text("spacing / 2")}
            Button { } label: {Text("spacing * 2")}
          }

      }
      .offset(x: legendsOffset)
    }
  }
}

//struct FrequencyLegendView_Previews: PreviewProvider {
//    static var previews: some View {
//      FrequencyLegendView(viewStore: ,
//                          panadapter: Panadapter(0x49999999),
//                          width: 800,
//                          color: .blue)
//    }
//}

// ----------------------------------------------------------------
// MARK: Supporting

func freqDrag(_ value: DragGesture.Value, _ width: CGFloat, _ bandWidth: inout CGFloat, _ startBandWidth: inout CGFloat?) {
  
  var pixelPerHz: CGFloat { width / bandWidth }
  
  if let start = startBandWidth {
    bandWidth = start + ((value.startLocation.x - value.location.x)/pixelPerHz)
  } else {
    startBandWidth = bandWidth
  }
//  print("bandWidth = \(bandWidth)")
}
