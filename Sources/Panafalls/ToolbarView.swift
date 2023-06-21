//
//  SwiftUIView.swift
//  
//
//  Created by Douglas Adams on 6/7/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

public struct ToolbarView: View {
  let viewStore: ViewStore<PanafallsFeature.State, PanafallsFeature.Action>
  @ObservedObject var radio: Radio
  
  @Environment(\.openWindow) var openWindow

  @Dependency(\.apiModel) var apiModel
  
  public var body: some View {
    HStack {
      Spacer()
      Button("+Pan") { viewStore.send(.panadapterButton) }
      Spacer()
      Group {
        Toggle("Tnfs", isOn: viewStore.binding( get: {_ in radio.tnfsEnabled }, send: { .tnfButton($0) }))
        Toggle("CWX", isOn: viewStore.binding( get: {_ in false }, send: { .cwxButton($0) }))     // FIXME:
        Toggle("FDX", isOn: viewStore.binding( get: {_ in radio.fullDuplexEnabled }, send: { .fdxButton($0) }))
        Spacer()
        Toggle("Markers", isOn: viewStore.binding( get: \.markers, send: { .markerButton($0) }))
        Toggle("RxAudio", isOn: viewStore.binding( get: \.rxAudio, send: { .rxAudioButton($0) }))
        Toggle("TxAudio", isOn: viewStore.binding( get: \.txAudio, send: { .txAudioButton($0) }))
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
      Button { openWindow(id: "Controls") } label: { Image(systemName: "square.trailingthird.inset.filled") }
    }
  }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
      ToolbarView(viewStore: ViewStore(Store(initialState: PanafallsFeature.State(), reducer: PanafallsFeature())), radio: Radio(Packet()))
        .frame(width: 900)
    }
}
