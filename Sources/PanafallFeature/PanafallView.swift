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
  
  @State private var freqSpacing: CGFloat = 20_000
  @State private var dbmSpacing: CGFloat = 10
  
  let legendColor: Color = .green
  let linesColor: Color = .gray
  let frequencyLegendHeight: CGFloat = 30
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      
      VStack {
        
        Text("----- Panadapters -----")
        
        ForEach(objectModel.panadapters) { panadapter in
          GeometryReader { g in
            VStack(alignment: .leading, spacing: 0) {
              
              ZStack {
                // Vertical lines
                FrequencyLinesView(panadapter: panadapter,
                                   spacing: freqSpacing,
                                   width: g.size.width,
                                   height: g.size.height - frequencyLegendHeight,
                                   color: linesColor)
                
                // Horizontal lines
                DbmLinesView(panadapter: panadapter,
                             spacing: dbmSpacing,
                             width: g.size.width,
                             height: g.size.height - frequencyLegendHeight,
                             color: linesColor)
                
                // DbmLegend
                DbmLegendView(viewStore: viewStore,
                              panadapter: panadapter,
                              spacing: dbmSpacing,
                              width: g.size.width,
                              height: g.size.height - frequencyLegendHeight,
                              color: legendColor)
              }
              
              // Frequency Legend
              Divider().background(legendColor)
              FrequencyLegendView(panadapter: panadapter,
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
