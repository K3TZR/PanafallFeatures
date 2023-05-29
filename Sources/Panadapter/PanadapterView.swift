//
//  PanadapterView.swift
//  
//
//  Created by Douglas Adams on 4/16/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct PanadapterView: View {
  let store: StoreOf<PanadapterFeature>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var panadapterStream: PanadapterStream
  @ObservedObject var objectModel: ObjectModel

  public init(store: StoreOf<PanadapterFeature>, panadapter: Panadapter, panadapterStream: PanadapterStream, objectModel: ObjectModel) {
    self.store = store
    self.panadapter = panadapter
    self.panadapterStream = panadapterStream
    self.objectModel = objectModel
  }
  
  @Dependency(\.apiModel) var apiModel
  
  let frequencyLegendHeight: CGFloat = 30
  let spacings = [
    (10_000_000, 1_000_000),
    (5_000_000, 500_000),
    (1_000_000, 100_000),
    (500_000, 50_000),
    (400_000, 40_000),
    (300_000, 30_000),
    (200_000, 20_000),
    (100_000, 10_000),
    (50_000, 5_000),
    (40_000, 4_000),
    (30_000, 3_000),
    (20_000, 2_000),
    (10_000, 1_000)
  ]
  let formats = [
    (1_000_000,"%01.0f"),
    (500_000,"%01.0f"),
    (100_000,"%01.0f"),
    (50_000,"%02.3f"),
    (40_000,"%02.3f"),
    (30_000,"%02.3f"),
    (20_000,"%02.3f"),
    (10_000,"%02.3f"),
    (5_000,"%02.3f"),
    (4_000,"%02.3f"),
    (3_000,"%02.3f"),
    (2_000,"%02.3f"),
    (1_000,"%02.3f")
  ]
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VSplitView {
//        ForEach(objectModel.panadapters) { panadapter in
          GeometryReader { g in
            VStack(alignment: .leading, spacing: 0) {
              
              ZStack(alignment: .leading) {
                // Spectrum
                SpectrumView(panadapterStream: panadapterStream)
                
                // Vertical lines
                FrequencyLinesView(viewStore: viewStore, panadapter: panadapter, spacings: spacings)
                
                // Horizontal lines
                DbmLinesView(panadapter: panadapter, size: g.size)
                
                // DbmLegend
                DbmLegendView(viewStore: viewStore, panadapter: panadapter, size: g.size)
                
                // Slice(s)
                ForEach(objectModel.slices) { slice in
                  if slice.frequency >= panadapter.center - panadapter.bandwidth/2 &&
                      slice.frequency <= panadapter.center + panadapter.bandwidth/2
                  {
                    SliceView(viewStore: viewStore,
                              panadapter: panadapter,
                              slice: slice,
                              width: g.size.width)
                  }
                }
                
                // Tnf(s)
                ForEach(objectModel.tnfs) { tnf in
                  TnfView(viewStore: viewStore,
                          panadapter: panadapter,
                          tnf: tnf,
                          radio: apiModel.radio!,
                          width: g.size.width)
                }
              }.frame(height: g.size.height - frequencyLegendHeight)

              
              // Frequency Legend
              Divider().background(.green)
              FrequencyLegendView(viewStore: viewStore,
                                  panadapter: panadapter,
                                  size: g.size,
                                  spacings: spacings,
                                  formats: formats)
              .frame(height: frequencyLegendHeight)
            }
            
            .onChange(of: g.size , perform: {_ in
              viewStore.send(.panadapterSize(panadapter, g.size))
            })
          }
//        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct PanadapterView_Previews: PreviewProvider {
  
  static var previews: some View {
    PanadapterView( store: Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature()),
                    panadapter: Panadapter(0x49999990),
                    panadapterStream: PanadapterStream(0x49999990),
                    objectModel: ObjectModel())
    .frame(width:800, height: 600)
  }
}
