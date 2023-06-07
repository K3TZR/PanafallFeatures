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
      VSplitView {
        ForEach(objectModel.panadapters) { panadapter in
          VStack {
            PanafallView(store: Store(initialState: PanafallFeature.State(), reducer: PanafallFeature()),
                         panadapter: panadapter)
            Divider()
              .frame(height: 3)
              .background(Color.gray)
          }.border(.green)
        }
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
        .border(.red)
      }
      .toolbar {
        if apiModel.radio != nil {
          ToolbarView(viewStore: viewStore, radio: apiModel.radio!)
        }
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
