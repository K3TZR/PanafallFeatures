//
//  FrequencyLegendView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import SwiftUI

import FlexApi

struct FrequencyLegendView: View {
  @ObservedObject var panadapter: Panadapter
  let width: CGFloat
  let color: Color
  
  var params: (spacing: CGFloat, format: String) { legendParams }
  var low: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var high: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var xOffset: CGFloat { -low.truncatingRemainder(dividingBy: params.spacing) }
  var pixelPerHz: CGFloat { width / (high - low)}
  var legendWidth: CGFloat { pixelPerHz * params.spacing }
  var legendsOffset: CGFloat { xOffset * pixelPerHz }

  typealias FrequencyParam = (bandwidth: Int, spacing: CGFloat, format: String)
  var legendParams: (spacing: CGFloat, format: String) {
    let params = [
      FrequencyParam(10_000_000, 1_000_000, "%01.0f"),
      FrequencyParam(5_000_000, 50_000, "%01.1f"),
      FrequencyParam(1_000_000, 50_000, "%01.1f"),
      FrequencyParam(500_000, 50_000, "%02.3f"),
      FrequencyParam(400_000, 50_000, "%02.3f"),
      FrequencyParam(300_000, 20_000, "%02.3f"),
      FrequencyParam(200_000, 20_000, "%02.3f"),
      FrequencyParam(100_000, 50_000, "%02.3f"),
      FrequencyParam(50_000, 5_000, "%02.3f"),
      FrequencyParam(40_000, 4_000, "%02.3f"),
      FrequencyParam(30_000, 3_000, "%02.3f"),
      FrequencyParam(20_000, 2_000, "%02.3f"),
      FrequencyParam(10_000, 1_000, "%02.3f")
    ]
    
    for param in params {
      if panadapter.bandwidth >= param.bandwidth { return (param.spacing, param.format) }
    }
    return (params[0].spacing, params[0].format)
  }
  
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
              .onChanged { drag in
                print("Frequency Legend drag")
//                if let start = startBandWidth {
//                  DispatchQueue.main.async { bandWidth = start + ((drag.startLocation.x - drag.location.x)/pixelPerHz) }
//                } else {
//                  startBandWidth = bandWidth
//                }
              }
              .onEnded { _ in
                print("Frequency Legend drag END")
//                startBandWidth = nil
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

struct FrequencyLegendView_Previews: PreviewProvider {
    static var previews: some View {
      FrequencyLegendView(panadapter: Panadapter(0x49999999),
                          width: 800,
                          color: .blue)
    }
}

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
