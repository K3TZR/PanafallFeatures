//
//  PanafallView.swift
//  
//
//  Created by Douglas Adams on 5/20/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Panadapter
import AntennaPopover
import BandPopover
import DisplayPopover
import DaxPopover

public struct PanafallView: View {
  let store: StoreOf<PanafallFeature>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var waterfall: Waterfall
  
  public init(store: StoreOf<PanafallFeature>,
              panadapter: Panadapter,
              waterfall: Waterfall) {
    self.store = store
    self.panadapter = panadapter
    self.waterfall = waterfall
  }

  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel
  
  @State var width: CGFloat = 60
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HSplitView {
        VStack {
          TopButtonsView(store: store, panadapter: panadapter, waterfall: waterfall)
          Spacer()
          BottomButtonsView(store: store, panadapter: panadapter, waterfall: waterfall)
        }
        .frame(width: width)
        .padding(.vertical, 10)

        VSplitView {
          PanadapterView(store: Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature()),
                         panadapter: panadapter,
                         panadapterStream: streamModel.panadapterStreams[id: panadapter.id]!,
                         objectModel: objectModel)
          .frame(minWidth: 900, minHeight: 450)
          Text("Waterfall View")
            .frame(minWidth: 900, minHeight: 100)
        }
      }
    }
  }
}

private struct TopButtonsView: View {
  let store: StoreOf<PanafallFeature>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var waterfall: Waterfall

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(spacing: 20) {
        Button("Band") { viewStore.send(.bandButton) }
          .popover(isPresented: viewStore.binding(get: { $0.bandPopover }, send: .bandButton ), arrowEdge: .trailing) {
            BandView(store: Store(initialState: BandFeature.State(), reducer: BandFeature()),
                     panadapter: panadapter)
          }
        
        Button("Antenna") { viewStore.send(.antennaButton) }
          .popover(isPresented: viewStore.binding(get: { $0.antennaPopover }, send: .antennaButton ), arrowEdge: .trailing) {
            AntennaView(store: Store(initialState: AntennaFeature.State(), reducer: AntennaFeature()),
                        panadapter: panadapter)
          }
        
        Button("Display") { viewStore.send(.displayButton) }
          .popover(isPresented: viewStore.binding(get: { $0.displayPopover }, send: .displayButton ), arrowEdge: .trailing) {
            DisplayView(store: Store(initialState: DisplayFeature.State(), reducer: DisplayFeature()),
                        panadapter: panadapter,
                        waterfall: waterfall)
          }
        Button("Dax") { viewStore.send(.daxButton) }
          .popover(isPresented: viewStore.binding(get: { $0.daxPopover }, send: .daxButton ), arrowEdge: .trailing) {
            DaxView(store: Store(initialState: DaxFeature.State(), reducer: DaxFeature()),
                    panadapter: panadapter)
          }
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}

private struct BottomButtonsView: View {
  let store: StoreOf<PanafallFeature>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var waterfall: Waterfall

  @State var width: CGFloat = 60
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(spacing: 20) {
        HStack {
          Image(systemName: "s.circle")
            .onTapGesture {
              viewStore.send(.zoomButton(panadapter, .segment))
            }
          Image(systemName: "b.circle")
            .onTapGesture {
              viewStore.send(.zoomButton(panadapter, .band))
            }
        }
        HStack {
          Image(systemName: "minus.circle")
            .onTapGesture {
              viewStore.send(.zoomButton(panadapter, .minus))
            }
          Image(systemName: "plus.circle")
            .onTapGesture {
              viewStore.send(.zoomButton(panadapter, .plus))
            }
        }
      }.font(.title2)
    }
  }
}

struct PanafallView_Previews: PreviewProvider {
  static var previews: some View {
    PanafallView(store: Store(initialState: PanafallFeature.State(), reducer: PanafallFeature()),
                 panadapter: Panadapter(0x49999990),
                 waterfall: Waterfall(0x49999991)
    )
  }
}