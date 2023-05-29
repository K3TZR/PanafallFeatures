//
//  DisplayView.swift
//  ViewFeatures/DisplayFeature
//
//  Created by Douglas Adams on 12/21/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

public struct DisplayView: View {
  let store: StoreOf<DisplayFeature>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var waterfall: Waterfall

  public init(store: StoreOf<DisplayFeature>, panadapter: Panadapter, waterfall: Waterfall) {
    self.store = store
    self.panadapter = panadapter
    self.waterfall = waterfall
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      
      VStack(alignment: .leading) {
        PanadapterSettings(viewStore: viewStore, panadapter: panadapter)
        Divider().foregroundColor(.blue)
        WaterfallSettings(viewStore: viewStore, waterfall: waterfall)
      }
      .frame(width: 250)
      .padding(5)
    }
  }
}

private struct PanadapterSettings: View {
  let viewStore: ViewStore<DisplayFeature.State, DisplayFeature.Action>
  @ObservedObject var panadapter: Panadapter

  @AppStorage("spectrumFillLevel") var spectrumFillLevel: Double = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 10) {
        Text("Average").frame(width: 90, alignment: .leading)
        Text("\(panadapter.average)").frame(width: 25, alignment: .trailing)
        Slider(value: viewStore.binding(get: {_ in Double(panadapter.average) }, send: { .panadapterProperty(panadapter, .average, String(Int($0))) }), in: 0...100)
      }
      HStack(spacing: 10) {
        Text("Frames/sec").frame(width: 90, alignment: .leading)
        Text("\(panadapter.fps)").frame(width: 25, alignment: .trailing)
        Slider(value: viewStore.binding(get: {_ in Double(panadapter.fps) }, send: { .panadapterProperty(panadapter, .fps, String(Int($0))) }), in: 0...100)
      }
      HStack(spacing: 10) {
        Text("Fill").frame(width: 90, alignment: .leading)
        Text("\(Int(spectrumFillLevel))").frame(width: 25, alignment: .trailing)
        Slider(value: $spectrumFillLevel, in: 0...100)
//        Slider(value: viewStore.binding(get: {_ in Double(panadapter.fillLevel) }, send: { .panadapterProperty(panadapter, .fillLevel, String(Int($0))) }), in: 0...100)
      }
      HStack {
        Text("Weighted Average").frame(width: 130, alignment: .leading)
        Toggle("", isOn: viewStore.binding(
          get: {_ in panadapter.weightedAverageEnabled },
          send: { .panadapterProperty(panadapter, .weightedAverageEnabled, $0.as1or0 ) } ))
      }
    }
  }
}

private struct WaterfallSettings: View {
  let viewStore: ViewStore<DisplayFeature.State, DisplayFeature.Action>
  @ObservedObject var waterfall: Waterfall

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack (spacing: 45){
        Text("Color Gradient")
        Picker("", selection: viewStore.binding(
          get: {_ in  waterfall.gradientIndex},
          send: { .waterfallProperty(waterfall, .gradientIndex, String($0)) })) {
            ForEach(Array(Waterfall.gradients.enumerated()), id: \.offset) { index, element in
              Text(element).tag(index)
            }
          }
          .labelsHidden()
          .pickerStyle(.menu)
          .frame(width: 70, alignment: .leading)
      }
      
      HStack(spacing: 10) {
        Text("Color Gain").frame(width: 90, alignment: .leading)
        Text("\(waterfall.colorGain)").frame(width: 25, alignment: .trailing)
        Slider(value: viewStore.binding(get: {_ in Double(waterfall.colorGain) }, send: { .waterfallProperty(waterfall, .colorGain, String(Int($0))) }), in: 0...100)
      }
      HStack(spacing: 10) {
        Text("Auto Black").frame(width: 65, alignment: .leading)
        Toggle("", isOn: viewStore.binding(
          get: {_ in  waterfall.autoBlackEnabled },
          send: { .waterfallProperty(waterfall, .autoBlackEnabled, $0.as1or0) } )).labelsHidden()
        Text("\(waterfall.blackLevel)").frame(width: 25, alignment: .trailing)
        Slider(value: viewStore.binding(get: {_ in Double(waterfall.blackLevel) }, send: { .waterfallProperty(waterfall, .blackLevel, String(Int($0))) }), in: 0...100)
      }
      HStack(spacing: 10) {
        Text("Line Duration").frame(width: 90, alignment: .leading)
        Text("\(waterfall.lineDuration)").frame(width: 25, alignment: .trailing)
        Slider(value: viewStore.binding(get: {_ in Double(waterfall.lineDuration) }, send: { .waterfallProperty(waterfall, .lineDuration, String(Int($0))) }), in: 0...100)
      }
    }
  }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
      DisplayView(store: Store(initialState: DisplayFeature.State(), reducer: DisplayFeature()),
                  panadapter: Panadapter(0x49999990),
                  waterfall: Waterfall(0x49999991))
        .frame(width: 250)
        .padding(5)
    }
}
