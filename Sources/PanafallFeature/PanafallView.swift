//
//  PanafallView.swift
//  
//
//  Created by Douglas Adams on 4/16/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

public struct PanafallView: View {
  let store: StoreOf<PanafallFeature>
  @ObservedObject var objectModel: ObjectModel
  
  public init(store: StoreOf<PanafallFeature>, objectModel: ObjectModel) {
    self.store = store
    self.objectModel = objectModel
  }
  
  let legendColor: Color = .green
  let linesColor: Color = .gray
  let frequencyLegendHeight: CGFloat = 30
  
  typealias SpacingParam = (bandwidth: Int, spacing: CGFloat, format: String)
  func spacing(_ bandwidth: Int) -> (spacing: CGFloat, format: String) {
    let list = [
      SpacingParam(10_000_000, 1_000_000, "%01.0f"),
      SpacingParam(5_000_000, 50_000, "%01.1f"),
      SpacingParam(1_000_000, 50_000, "%01.1f"),
      SpacingParam(500_000, 50_000, "%02.3f"),
      SpacingParam(400_000, 50_000, "%02.3f"),
      SpacingParam(300_000, 20_000, "%02.3f"),
      SpacingParam(200_000, 20_000, "%02.3f"),
      SpacingParam(100_000, 50_000, "%02.3f"),
      SpacingParam(50_000, 5_000, "%02.3f"),
      SpacingParam(40_000, 4_000, "%02.3f"),
      SpacingParam(30_000, 3_000, "%02.3f"),
      SpacingParam(20_000, 2_000, "%02.3f"),
      SpacingParam(10_000, 1_000, "%02.3f")
    ]

    for param in list {
      if bandwidth >= param.bandwidth { return (param.spacing, param.format) }
    }
    return (list[0].spacing, list[0].format)
  }

  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      
      VStack {
        
        Text("----- Panadapters -----")
        
        ForEach(objectModel.panadapters) { panadapter in
          GeometryReader { g in
            VStack(alignment: .leading, spacing: 0) {
              
              ZStack {
                // Vertical lines
                FrequencyLinesView(viewStore: viewStore,
                                   panadapter: panadapter,
                                   params: spacing(panadapter.bandwidth),
                                   width: g.size.width,
                                   height: g.size.height - frequencyLegendHeight,
                                   color: linesColor)
                
                // Horizontal lines
                DbmLinesView(panadapter: panadapter,
                             spacing: viewStore.dbmSpacing,
                             width: g.size.width,
                             height: g.size.height - frequencyLegendHeight,
                             color: linesColor)
                
                // DbmLegend
                DbmLegendView(viewStore: viewStore,
                              panadapter: panadapter,
                              spacing: viewStore.dbmSpacing,
                              width: g.size.width,
                              height: g.size.height - frequencyLegendHeight,
                              color: legendColor)
              }
              
              // Frequency Legend
              Divider().background(legendColor)
              FrequencyLegendView(viewStore: viewStore,
                                  panadapter: panadapter,
                                  params: spacing(panadapter.bandwidth),
                                  width: g.size.width,
                                  color: legendColor)
              .frame(height: frequencyLegendHeight)
            }
          }
        }
      }
      .frame(minWidth: 500, minHeight: 200)
    }
  }
}

struct PanafallView_Previews: PreviewProvider {
  static var previews: some View {
    PanafallView( store: Store(initialState: PanafallFeature.State(), reducer: PanafallFeature()),
                  objectModel: ObjectModel())
    .frame(width: 1000)
  }
}
