//
//  DaxView.swift
//  ViewFeatures/DaxFeature
//
//  Created by Douglas Adams on 12/21/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

public struct DaxView: View {
  let store: StoreOf<DaxFeature>
  @ObservedObject var panadapter: Panadapter
  
  public init(store: StoreOf<DaxFeature>, panadapter: Panadapter) {
    self.store = store
    self.panadapter = panadapter
  }
  
  public var body: some View {
    
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading) {
        
        HStack(spacing: 5) {
          Text("Dax IQ Channel")
          Picker("", selection: viewStore.binding(
            get: {_ in  panadapter.daxIqChannel },
            send: { .panadapterProperty( panadapter, .daxIqChannel, String($0)) })) {
              ForEach(panadapter.daxIqChoices, id: \.self) {
                Text(String($0)).tag($0)
              }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 50, alignment: .leading)
        }
      }
      .frame(width: 160)
      .padding(5)
    }
  }
}

struct DaxView_Previews: PreviewProvider {
    static var previews: some View {
      DaxView(store: Store(initialState: DaxFeature.State(), reducer: DaxFeature()), panadapter: Panadapter(0x49999999))
        .frame(width: 160)
        .padding(5)
    }
}
