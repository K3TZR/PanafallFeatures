//
//  BandView.swift
//  ViewFeatures/BandFeature
//
//  Created by Douglas Adams on 12/20/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

public struct BandView: View {
  let store: StoreOf<BandFeature>
  @ObservedObject var panadapter: Panadapter
  
  public init(
    store: StoreOf<BandFeature>,
    panadapter: Panadapter
  )
  {
    self.store = store
    self.panadapter = panadapter
  }
  
  let bandList = [
    "160","80","60",
    "40","30","20",
    "17","15","12",
    "10","6","4",
    "","WWV","GEN",
    "2200","6300","XVTR",
  ]

  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      
      Grid(alignment: .leading, horizontalSpacing: 2, verticalSpacing: 5) {
        RowView(store: store, panadapter: panadapter, bands: bandList[0...2])
        RowView(store: store, panadapter: panadapter, bands: bandList[3...5])
        RowView(store: store, panadapter: panadapter, bands: bandList[6...8])
        RowView(store: store, panadapter: panadapter, bands: bandList[9...11])
        RowView(store: store, panadapter: panadapter, bands: bandList[12...14])
        RowView(store: store, panadapter: panadapter, bands: bandList[15...17])
      }
    }
    .frame(width: 160)
    .padding(5)
  }
}

struct RowView: View {
  let store: StoreOf<BandFeature>
  @ObservedObject var panadapter: Panadapter
  let bands: ArraySlice<String>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      
      GridRow(alignment: .center) {
        ForEach(bands, id: \.self) { band in
          Toggle(isOn: viewStore.binding(
            get: { _ in  panadapter.band == band && !band.isEmpty},
            send: .panadapterProperty(panadapter, .band, band) ))
          { Text(band).frame(width: 35) }
            .toggleStyle(.button)
        }
      }
    }
  }
}
struct BandView_Previews: PreviewProvider {
  static var previews: some View {
    BandView(store: Store(initialState: BandFeature.State(),
                        reducer: BandFeature()),
           panadapter: Panadapter("0x99999999".streamId!))
  }
}
