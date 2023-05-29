//
//  AntennaView.swift
//  ViewFeatures/AntennaFeature
//
//  Created by Douglas Adams on 12/21/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

public struct AntennaView: View {
  let store: StoreOf<AntennaFeature>
  @ObservedObject var panadapter: Panadapter
  
  public init(store: StoreOf<AntennaFeature>, panadapter: Panadapter) {
    self.store = store
    self.panadapter = panadapter
  }
  
  public var body: some View {
    
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading) {
        HStack(spacing: 45) {
          Text("RxAnt")
          Picker("RxAnt", selection: viewStore.binding(
            get: {_ in  panadapter.rxAnt },
            send: { .panadapterProperty(panadapter, .rxAnt, $0) })) {
              ForEach(panadapter.antList, id: \.self) {
                Text($0).tag($0)
              }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 70, alignment: .leading)
        }
        Toggle("Loop A", isOn: viewStore.binding(
          get: {_ in panadapter.loopAEnabled },
          send: { .panadapterProperty(panadapter, .loopAEnabled, $0.as1or0 ) } ))
        .toggleStyle(.button)
        
        HStack {
          Text("Rf Gain")
          Text("\(panadapter.rfGain)").frame(width: 25, alignment: .trailing)
          Slider(value: viewStore.binding(get: {_ in Double(panadapter.rfGain) }, send: { .panadapterProperty(panadapter, .rfGain, String(Int($0))) }), in: -10...20, step: 10)
        }
      }
    }
    .frame(width: 160)
    .padding(5)
  }
}

struct AntennaView_Previews: PreviewProvider {
  static var previews: some View {
    AntennaView(store: Store(initialState: AntennaFeature.State(), reducer: AntennaFeature()), panadapter: Panadapter(0x49999999))
      .frame(width: 160)
      .padding(5)
  }
}
