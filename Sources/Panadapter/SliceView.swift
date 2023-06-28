//
//  SliceView.swift
//
//
//  Created by Douglas Adams on 5/17/23.
//

import AppKit
import ComposableArchitecture
import SwiftUI

import Flag
import FlexApi
import Shared

struct SliceView: View {
  var viewStore: ViewStore<PanadapterFeature.State, PanadapterFeature.Action>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var slice: Slice
  let width: CGFloat
    
  @AppStorage("sliceFilterColor") var sliceFilterColor = DefaultColors.sliceFilterColor
  @AppStorage("sliceActiveColor") var sliceActiveColor = DefaultColors.sliceActiveColor
  @AppStorage("sliceInactiveColor") var sliceInactiveColor = DefaultColors.sliceInactiveColor
  
  @State var startFrequency: CGFloat?
  @State var cursorInSlice = false
  @State var smallFlag = false
  
  var panadapterLowFrequency: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var panadapterHighFrequency: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var panadapterCenter: CGFloat { CGFloat(panadapter.center) }
  var sliceFrequency: CGFloat { CGFloat(slice.frequency) }
  var sliceFilterLow: CGFloat { CGFloat(slice.filterLow) }
  var pixelPerHz: CGFloat { width / (panadapterHighFrequency - panadapterLowFrequency) }
  var sliceWidth: CGFloat { CGFloat(abs(slice.filterHigh - slice.filterLow)) }
  
  var sliceOffset: CGFloat { (sliceFrequency - panadapterLowFrequency) * pixelPerHz }
  var flagWidth: CGFloat { smallFlag ? 150 : 275 }
  var flagOffset: CGFloat { sliceOffset <= flagWidth ? sliceOffset : sliceOffset - flagWidth }
  
  
  var body: some View {
    //    let _ = Self._printChanges()
    
    ZStack(alignment: .topLeading) {
      if sliceFrequency < panadapterLowFrequency {
        VStack {
          Spacer()
          Text("< \(slice.sliceLetter!)").font(.title)
            .offset(x: 40)
          Spacer()
        }
      }
      if sliceFrequency > panadapterHighFrequency {
        VStack {
          Spacer()
          Text("\(slice.sliceLetter!) >").font(.title)
            .offset(x: width - 80)
          Spacer()
        }
      }

      FlagView(store: Store(initialState: FlagFeature.State(slice: slice), reducer: FlagFeature()), smallFlag: $smallFlag)
        .offset(x: flagOffset)
      
      Rectangle()
        .frame(width: 2)
        .foregroundColor(slice.active ? sliceActiveColor : sliceInactiveColor)
        .offset(x: (sliceFrequency - panadapterLowFrequency) * pixelPerHz)
      
      Rectangle()
        .fill(sliceFilterColor)
        .border(cursorInSlice ? .red : sliceFilterColor)
        .frame(width: sliceWidth * pixelPerHz)
        .contentShape(Rectangle())
        .offset(x: (sliceFrequency + sliceFilterLow - panadapterLowFrequency) * pixelPerHz)
      
        .onHover {
          cursorInSlice = $0
        }
      
      // left-drag Slice frequency
        .gesture(
          DragGesture(minimumDistance: pixelPerHz)
            .onChanged { value in
              if let startFrequency {
                //                if abs(value.translation.width) > pixelPerHz {
                
                let currentCenter = panadapterCenter
                let frequencyDelta: CGFloat = value.translation.width/pixelPerHz
                let newFrequency = startFrequency + frequencyDelta
                
                //                  let newCenter = newFrequency < panadapterLowFrequency ? newCenter : nil
//                let newIntCenter = newFrequency < panadapterLowFrequency ? Int(newCenter) : nil
                viewStore.send(.sliceDrag(panadapter, slice, Int(newFrequency), frequencyDelta))
                
                //                  print("----->>>>> delta  = \(frequencyDelta)")
                //                  print("----->>>>> center = \(currentCenter - frequencyDelta)")
                
                //                  viewStore.send(.frequencyLinesDrag(panadapter, Int(currentCenter - frequencyDelta)))
                
                //                }
                //                  let low : Hz = await panadapter.center - panadapter.bandwidth/2
                //                  let new: Hz = newFrequency
                //                  let center: Hz = await panadapter.center
                //
                //                  if new < low {
                //
                //                    print("center = \(center), low = \(low), newFrequency = \(new), move = \(low - new), newCenter = \(center - (low - new))")
                //
                //                    let newCenter = center - (low - new)
                //                    await panadapter.setProperty(.center, newCenter.hzToMhz)
                //                  }
                
                
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
