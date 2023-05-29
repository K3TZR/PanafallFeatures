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

  public var body: some View {
      VSplitView {
        ForEach(objectModel.panadapters) { panadapter in
          PanafallView(store: Store(initialState: PanafallFeature.State(), reducer: PanafallFeature()),
                       panadapter: panadapter,
                       waterfall: objectModel.waterfalls[id: panadapter.waterfallId]!)
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
