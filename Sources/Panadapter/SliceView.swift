//
//  SliceView.swift
//
//
//  Created by Douglas Adams on 5/17/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

struct SliceView: View {
  var viewStore: ViewStore<PanadapterFeature.State, PanadapterFeature.Action>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var slice: Slice
  let width: CGFloat
  
  static let opacity: CGFloat = 0.2
  
  @AppStorage("sliceBackgroundColor") var sliceBackgroundColor = Color.white.opacity(opacity)
  @AppStorage("sliceActiveColor") var sliceActiveColor = Color.red
  @AppStorage("sliceInactiveColor") var sliceInactiveColor = Color.yellow

  @State var startFrequency: CGFloat?
  @State var cursorInSlice = false

  var panadapterLowFrequency: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var panadapterHighFrequency: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var panadapterCenter: CGFloat { CGFloat(panadapter.center) }
  var sliceFrequency: CGFloat { CGFloat(slice.frequency) }
  var sliceFilterLow: CGFloat { CGFloat(slice.filterLow) }
  var pixelPerHz: CGFloat { width / (panadapterHighFrequency - panadapterLowFrequency) }
  var sliceWidth: CGFloat { CGFloat(abs(slice.filterHigh - slice.filterLow)) }
  
  var body: some View {
    ZStack(alignment: .leading) {
      
      Rectangle()
        .frame(width: 2)
        .foregroundColor(slice.active ? sliceActiveColor : sliceInactiveColor)
        .offset(x: (sliceFrequency - panadapterLowFrequency) * pixelPerHz)
        

      Rectangle()
        .fill(sliceBackgroundColor)
        .border(cursorInSlice ? .red : sliceBackgroundColor)
        .frame(width: sliceWidth * pixelPerHz)
        .offset(x: (sliceFrequency + sliceFilterLow - panadapterLowFrequency) * pixelPerHz)

        .onHover { isInsideView in
          cursorInSlice = isInsideView
        }




      // left-drag Slice frequency
        .gesture(
          DragGesture(minimumDistance: pixelPerHz)
            .onChanged { value in
              if let startFrequency {
                if abs(value.translation.width) > pixelPerHz {
                  let newFrequency = Int(startFrequency + (value.translation.width/pixelPerHz))
                  viewStore.send(.sliceDrag(slice, newFrequency))
                }
              } else {
                startFrequency = CGFloat(slice.frequency)
              }
            }
            .onEnded { value in
              startFrequency = nil
            }
        )
      
        .contextMenu {
          Button("Delete Slice") { viewStore.send(.sliceRemove(slice.id)) }
          Divider()
          Text("Freq: \(slice.frequency.hzToMhz)")
          Text(" width: \(Int(sliceWidth))")
        }
    }
  }
}

struct SliceView_Previews: PreviewProvider {
  
  static var previews: some View {
    SliceView(viewStore: ViewStore(Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature())),
              panadapter: Panadapter(0x49999999),
              slice: Slice(1),
              width: 800)
  }
}
