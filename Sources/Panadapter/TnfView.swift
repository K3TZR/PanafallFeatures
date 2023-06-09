//
//  TnfView.swift
//  
//
//  Created by Douglas Adams on 5/17/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

struct TnfView: View {
  var viewStore: ViewStore<PanadapterFeature.State, PanadapterFeature.Action>
  @ObservedObject var panadapter: Panadapter
  @ObservedObject var tnf: Tnf
  @ObservedObject var radio: Radio
  let size: CGSize

  @AppStorage("tnfDeepColor") var tnfDeepColor = DefaultColors.tnfDeepColor
  @AppStorage("tnfInactiveColor") var tnfInactiveColor = DefaultColors.tnfInactiveColor
  @AppStorage("tnfNormalColor") var tnfNormalColor = DefaultColors.tnfNormalColor
  @AppStorage("tnfVeryDeepColor") var tnfVeryDeepColor = DefaultColors.tnfVeryDeepColor
  @AppStorage("tnfPermanentColor") var tnfPermanentColor = DefaultColors.tnfPermanentColor

  static let minWidth: CGFloat = 1000

  @State var startFrequency: CGFloat?
  @State var cursorInTnf = false

  var panadapterLowFrequency: CGFloat { CGFloat(panadapter.center - panadapter.bandwidth/2) }
  var panadapterHighFrequency: CGFloat { CGFloat(panadapter.center + panadapter.bandwidth/2) }
  var tnfFrequency: CGFloat { CGFloat(tnf.frequency) }
  var pixelPerHz: CGFloat { size.width / (panadapterHighFrequency - panadapterLowFrequency) }

  var depthColor: Color {
    if radio.tnfsEnabled {
      switch tnf.depth {
      case Tnf.Depth.normal.rawValue:     return tnfNormalColor
      case Tnf.Depth.deep.rawValue:       return tnfDeepColor
      case Tnf.Depth.veryDeep.rawValue:   return tnfVeryDeepColor
      default:                            return tnfInactiveColor
      }
    } else {
      return tnfInactiveColor
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      
      Rectangle()
        .fill(tnf.permanent ? tnfPermanentColor : depthColor)
        .border(cursorInTnf ? .red : depthColor)
        .frame(width: max(CGFloat(tnf.width), TnfView.minWidth) * pixelPerHz, height: 0.1 * size.height)
        .offset(x: (tnfFrequency - panadapterLowFrequency) * pixelPerHz )
      
        .onHover { isInsideView in
          cursorInTnf = isInsideView
        }

      Rectangle()
        .fill(depthColor)
        .border(cursorInTnf ? .red : depthColor)
        .frame(width: max(CGFloat(tnf.width), TnfView.minWidth) * pixelPerHz, height: 0.9 * size.height)
        .offset(x: (tnfFrequency - panadapterLowFrequency) * pixelPerHz )
      
        .onHover { isInsideView in
          cursorInTnf = isInsideView
        }
    }
    
    // left-drag Tnf frequency
      .gesture(
        DragGesture(minimumDistance: pixelPerHz)
          .onChanged { value in
            if let startFrequency {
              if abs(value.translation.width) > pixelPerHz {
                let newFrequency = Int(startFrequency + (value.translation.width/pixelPerHz))
                viewStore.send(.tnfProperty(tnf, .frequency, newFrequency.hzToMhz))
              }
            } else {
              startFrequency = CGFloat(tnf.frequency)
            }
          }
          .onEnded { value in
            startFrequency = nil
          }
      )

      .contextMenu {
        Button("Delete Tnf") { viewStore.send(.tnfRemove(tnf.id)) }
        Divider()
        Text("Freq: \(tnf.frequency.hzToMhz)")
        Text(" width: \(tnf.width)")
        Button(action: { viewStore.send(.tnfProperty(tnf, .permanent, (!tnf.permanent).as1or0)) } ) {
          tnf.permanent ? Text("\(Image(systemName: "checkmark")) Permanent") : Text("Permanent")
        }
        Button(action: { viewStore.send(.tnfProperty(tnf, .depth, String(Tnf.Depth.normal.rawValue))) } ) {
          tnf.depth == Tnf.Depth.normal.rawValue ? Text("\(Image(systemName: "checkmark")) Normal") : Text("Normal")
        }
               
        Button(action: { viewStore.send(.tnfProperty(tnf, .depth, String(Tnf.Depth.deep.rawValue))) }) {
          tnf.depth == Tnf.Depth.deep.rawValue ? Text("\(Image(systemName: "checkmark")) Deep") : Text("Deep")
        }

        Button(action: { viewStore.send(.tnfProperty(tnf, .depth, String(Tnf.Depth.veryDeep.rawValue))) } ) {
          tnf.depth == Tnf.Depth.veryDeep.rawValue ? Text("\(Image(systemName: "checkmark")) Very Deep") : Text("Very Deep")
        }
        Divider()
        if radio.tnfsEnabled {
          Button("Disable Tnfs")  { viewStore.send(.tnfsEnable(false)) }
        } else {
          Button("Enable Tnfs")  { viewStore.send(.tnfsEnable(true)) }
        }
      }
  }
}

struct TnfView_Previews: PreviewProvider {
  
  static var previews: some View {
    TnfView(viewStore: ViewStore(Store(initialState: PanadapterFeature.State(), reducer: PanadapterFeature())),
            panadapter: Panadapter(0x49999999),
            tnf: Tnf(1),
            radio: Radio(Packet()),
            size: CGSize(width: 800, height: 800)
            )
  }
}
