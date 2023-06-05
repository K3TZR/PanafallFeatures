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
  
  public init(store: StoreOf<PanafallFeature>,
              panadapter: Panadapter) {
    self.store = store
    self.panadapter = panadapter
  }
  
  private let leftSideWidth: CGFloat = 60
  
  @AppStorage("leftSideIsOpen") var leftSideIsOpen = false
  @AppStorage("rightSideIsOpen") var rightSideIsOpen = false
  
  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HSplitView {
        if leftSideIsOpen {
          VStack {
            TopButtonsView(store: store, panadapter: panadapter, leftSideIsOpen: $leftSideIsOpen)
            Spacer()
            BottomButtonsView(store: store, panadapter: panadapter)
          }
          .frame(width: leftSideWidth)
          .padding(.vertical, 10)
        }
        
        ZStack(alignment: .topLeading) {
          VSplitView {
            PanadapterView(store: Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature()),
                           panadapter: panadapter,
                           objectModel: objectModel,
                           streamModel: streamModel,
                           leftWidth: leftSideIsOpen ? leftSideWidth : 0)
            .frame(minWidth: 500, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
            Text("Waterfall View: id = \(panadapter.waterfallId  == 0 ? "UNKNOWN" : panadapter.waterfallId.hex)")
              .frame(minWidth: 500, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
          }
          if leftSideIsOpen == false {
            Image(systemName: "arrowshape.right.fill").font(.title)
              .onTapGesture {
                leftSideIsOpen.toggle()
              }
          }
        }
      }
    }
  }
}

private struct TopButtonsView: View {
  let store: StoreOf<PanafallFeature>
  @ObservedObject var panadapter: Panadapter
  let leftSideIsOpen: Binding<Bool>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 20) {
        Image(systemName: "arrowshape.left.fill").font(.title)
          .onTapGesture {
            leftSideIsOpen.wrappedValue.toggle()
          }
        Image(systemName: "xmark.circle").font(.title)
          .onTapGesture {
            viewStore.send(.closeButton(panadapter.id))
          }
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
                        panadapter: panadapter)
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
                 panadapter: Panadapter(0x49999990)
    )
  }
}
