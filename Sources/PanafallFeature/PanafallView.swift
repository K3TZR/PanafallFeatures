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
  
//  @Dependency(\.objectModel) var objectModel
  
  @State private var center: CGFloat = 14_100_000
  @State private var bandWidth: CGFloat = 200_000
  @State private var freqSpacing: CGFloat = 20_000
  @State private var dbmHigh: CGFloat = 10
  @State private var dbmLow: CGFloat = -100
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
            //            Spacer()
            //            Text("Panadapter Window")
            //            Spacer()
            
            ZStack {
              //              // Vertical lines
              //              //              FrequencyLinesView(center: $center,
              //              //                                 dbmHigh: $dbmHigh,
              //              //                                 dbmLow: $dbmLow,
              //              //                                 bandWidth: bandWidth,
              //              //                                 spacing: freqSpacing,
              //              //                                 width: g.size.width,
              //              //                                 height: g.size.height - frequencyLegendHeight,
              //              //                                 color: linesColor)
              //
              // Horizontal lines
              DbmLinesView(panadapter: panadapter,
                           spacing: dbmSpacing,
                           width: g.size.width,
                           height: g.size.height - frequencyLegendHeight,
                           color: linesColor)
              
              // DbmLegend
              DbmLegendView(viewStore: viewStore,
                            panadapter: panadapter,
                            spacing: $dbmSpacing,
                            width: g.size.width,
                            height: g.size.height - frequencyLegendHeight,
                            color: legendColor)
            }
            
            // Frequency Legend
            //            Divider().background(legendColor)
            Spacer()
            Text("A Panadapter")
            Spacer()
            //            //            FrequencyLegendView(center: $center,
            //            //                                bandWidth: $bandWidth,
            //            //                                spacing: $freqSpacing,
            //            //                                width: g.size.width,
            //            //                                format: "%0.6f",
            //            //                                color: legendColor)
            //            //            .frame(height: frequencyLegendHeight)
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
    PanafallView( store: Store(initialState: PanafallFeature.State(),
                          reducer: PanafallFeature()),
             objectModel: ObjectModel())
    .frame(width: 1000)
  }
}
