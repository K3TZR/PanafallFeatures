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
  var viewStore: ViewStore<PanadapterFeature.State, PanadapterFeature.Action>
  @ObservedObject var panadapter: Panadapter
  let size: CGSize
  let spacings: [(Int,Int)]
  let formats: [(Int,String)]
  
  @State var startBandwidth: CGFloat?
  @AppStorage("frequencyLegend") var frequencyLegendColor: Color = .green
  
  private var xOffset: CGFloat { -CGFloat(panadapter.center - panadapter.bandwidth/2).truncatingRemainder(dividingBy: CGFloat(spacing)) }
  private var pixelPerHz: CGFloat { size.width / CGFloat(panadapter.bandwidth) }
  private var legendWidth: CGFloat { pixelPerHz * CGFloat(spacing) }
  private var legendOffset: CGFloat { xOffset * pixelPerHz }
  private var initialFrequency: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) + xOffset }
  
  private var spacing: Int {
    for spacing in spacings {
      if panadapter.bandwidth >= spacing.0 { return spacing.1 }
    }
    return spacings[0].1
  }
  
  private var format: String {
    for format in formats {
      if spacing >= format.0 { return format.1 }
    }
    return formats[0].1
  }
  
  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentFrequency = initialFrequency
    repeat {
      array.append( currentFrequency )
      currentFrequency += CGFloat(spacing)
    } while ( currentFrequency <= CGFloat(panadapter.center + panadapter.bandwidth/2) )
    return array
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Divider().background(frequencyLegendColor)
      HStack(spacing: 0) {
        ForEach(legends, id:\.self) { frequencyValue in
          Text(String(format: format, frequencyValue/1_000_000)).frame(width: legendWidth)
            .background(Color.white.opacity(0.1))
            .contentShape(Rectangle())
            .gesture(
              DragGesture()
                .onChanged { value in
                  if let startBandwidth {
                    let newBandwidth = Int(startBandwidth - (value.translation.width / pixelPerHz ))
                    viewStore.send(.frequencyLegendDrag(panadapter, newBandwidth))
                  } else {
                    startBandwidth = CGFloat(panadapter.bandwidth)
                  }
                }
                .onEnded { _ in
                  startBandwidth = nil
                }
            )
            .offset(x: -legendWidth/2 )
            .foregroundColor(frequencyLegendColor)
        }
        .offset(x: legendOffset)
      }
      Divider().background(frequencyLegendColor)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct FrequencyLegendView_Previews: PreviewProvider {
  
  static var pan: Panadapter {
    let p = Panadapter(0x49999999)
    p.center = 14_100_000
    p.bandwidth = 200_000
    p.maxDbm = 10
    p.minDbm = -120
    return p
  }
  
  static var previews: some View {
    FrequencyLegendView(viewStore: ViewStore(Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature())),
                        panadapter: pan,
                        size: CGSize(width: 900, height: 450),
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
                        ],
                        formats:[
                          (1_000_000,"%01.0f"),
                          (500_000,"%01.0f"),
                          (100_000,"%01.0f"),
                          (50_000,"%02.3f"),
                          (40_000,"%02.3f"),
                          (30_000,"%02.3f"),
                          (20_000,"%02.3f"),
                          (10_000,"%02.3f"),
                          (5_000,"%02.3f"),
                          (4_000,"%02.3f"),
                          (3_000,"%02.3f"),
                          (2_000,"%02.3f"),
                          (1_000,"%02.3f")
                        ])
    .frame(width: 900, height: 450)
  }
}

extension Color: RawRepresentable {
  public init?(rawValue: String) {
    guard let data = Data(base64Encoded: rawValue) else {
      self = .pink
      return
    }
    
    do {
      let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSColor ?? .systemPink
      self = Color(color)
    } catch {
      self = .pink
    }
  }
  
  public var rawValue: String {
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
      return data.base64EncodedString()
    } catch {
      return ""
    }
  }
}
