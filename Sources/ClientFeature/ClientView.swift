//
//  ClientFeature.swift
//  ViewFeatures/ClientFeature
//
//  Created by Douglas Adams on 1/19/22.
//

import ComposableArchitecture
import SwiftUI

import Shared

// ----------------------------------------------------------------------------
// MARK: - View(s)

// assumes that the number of GuiClients is 1 or 2

public struct ClientView: View {
  let store: StoreOf<ClientFeature>

  public init(store: StoreOf<ClientFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        Text(viewStore.heading).font(.title)
        Divider()
        Button( action: { viewStore.send(.connect( viewStore.selection, viewStore.handles[0] )) })
        { Text("Close " + viewStore.stations[0].uppercased() + " Station").frame(width: 150) }
        
        if viewStore.handles.count == 1 {
          Button( action: { viewStore.send(.connect( viewStore.selection, nil)) })
          { Text("MultiFlex connect").frame(width: 150) }
        }
        
        if viewStore.handles.count == 2 {
          Button( action: { viewStore.send(.connect( viewStore.selection, viewStore.handles[1] )) })
          { Text("Close " + viewStore.stations[1].uppercased() + " Station").frame(width: 150) }
        }
        
        Divider()
        
        Button( action: { viewStore.send(.cancelButton) })
        { Text("Cancel") }
          .keyboardShortcut(.cancelAction)
      }
    }
    .frame(maxWidth: 200)
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

struct ClientView_Previews: PreviewProvider {
  static var previews: some View {
    ClientView(store: Store(
      initialState: ClientFeature.State(selection: Pickable(packet: Packet(), station: ""),
                                        stations: ["iPad"],
                                        handles: [1,] ),
      reducer: ClientFeature())
    )
    .previewDisplayName("Gui connect (disconnect not required)")

    ClientView(store: Store(
      initialState: ClientFeature.State(selection: Pickable(packet: Packet(), station: ""),
                                        stations: ["iPad", "Windows"],
                                        handles: [1,2] ),
      reducer: ClientFeature())
    )
      .previewDisplayName("Gui connect (disconnect required)")
  }
}
