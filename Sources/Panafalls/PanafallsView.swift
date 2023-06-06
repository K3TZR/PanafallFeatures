//
//  PanafallsView.swift
//  
//
//  Created by Douglas Adams on 5/28/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Panafall

public struct PanafallsView: View {
  let store: StoreOf<PanafallsFeature>
  @ObservedObject var objectModel: ObjectModel

  public init(store: StoreOf<PanafallsFeature>, objectModel: ObjectModel) {
    self.store = store
    self.objectModel = objectModel
  }

  @Dependency(\.apiModel) var apiModel
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        if apiModel.radio != nil {
          MenuView(viewStore: viewStore, radio: apiModel.radio!)
            .frame(height: 30)
        }
        VSplitView {
          ForEach(objectModel.panadapters) { panadapter in
            PanafallView(store: Store(initialState: PanafallFeature.State(), reducer: PanafallFeature()),
                         panadapter: panadapter)
            Divider()
              .frame(height: 3)
              .background(Color.gray)
          }
        }
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
      }
    }
  }
}

private struct MenuView: View {
  let viewStore: ViewStore<PanafallsFeature.State, PanafallsFeature.Action>
  @ObservedObject var radio: Radio
  
  @Dependency(\.apiModel) var apiModel
  
  var body: some View {
    HStack {
      Spacer()
      Button("+Pan") { viewStore.send(.panadapterButton) }
      Spacer()
      Group {
        Toggle("Tnfs", isOn: viewStore.binding( get: {_ in radio.tnfsEnabled }, send: .tnfButton))
        Toggle("Markers", isOn: viewStore.binding( get: \.markers, send: .markerButton))
          .disabled(true)
        Toggle("RxAudio", isOn: viewStore.binding( get: \.rxAudio, send: .rxAudioButton))
        Toggle("TxAudio", isOn: viewStore.binding( get: \.txAudio, send: .txAudioButton))
      }.toggleStyle(.button)
      Spacer()
      HStack(spacing: 10) {
        Image(systemName: radio.lineoutMute ? "speaker.slash" : "speaker")
          .font(.system(size: 24, weight: .regular))
          .onTapGesture {
            viewStore.send(.lineoutMute(!radio.lineoutMute) )
          }
        Slider(value: viewStore.binding(get: {_ in Double(radio.lineoutGain) }, send: { .lineoutGain( Int($0) ) }), in: 0...100).frame(width: 150)
        
        Image(systemName: radio.headphoneMute ? "speaker.slash" : "speaker")
          .font(.system(size: 24, weight: .regular))
          .onTapGesture {
            viewStore.send(.headphoneMute(!radio.headphoneMute) )
          }
        Slider(value: viewStore.binding(get: {_ in Double(radio.headphoneGain) }, send: { .headphoneGain( Int($0) ) }), in: 0...100).frame(width: 150)
      }
    }
  }
}

struct PanafallsView_Previews: PreviewProvider {
    static var previews: some View {
      PanafallsView(store: Store(initialState: PanafallsFeature.State(), reducer: PanafallsFeature()),
                    objectModel: ObjectModel())
    }
}
