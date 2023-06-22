//
//  PanafallsView.swift
//  
//
//  Created by Douglas Adams on 5/28/23.
//

import ComposableArchitecture
import SwiftUI

import ApiStringView
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
      VStack {
        VSplitView {
          ForEach(objectModel.panadapters) { panadapter in
            VStack {
              PanafallView(store: Store(initialState: PanafallFeature.State(), reducer: PanafallFeature()),
                           panadapter: panadapter, apiModel: apiModel)
            }
          }
          .frame(minWidth: 500, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
        }
        Divider().frame(height: 2).background(Color.gray)
        FooterView(viewStore: viewStore, apiModel: apiModel)
      }
      .toolbar {
        if apiModel.radio != nil {
          ToolbarView(viewStore: viewStore, radio: apiModel.radio!)
        }
      }
    }
  }
}

private struct FooterView: View {
  let viewStore: ViewStore<PanafallsFeature.State, PanafallsFeature.Action>
  @ObservedObject var apiModel: ApiModel

  @AppStorage("stationName") public var stationName = "Sdr6000"

  var utc: String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.string(from: Date())
  }
  
  var body: some View {
    HStack {
      Spacer()
      HStack(spacing: 5) {
        Text("Station:")
//        TextField("Station name", text: viewStore.binding(get: {_ in apiModel.stationName}, send: { .stationName($0) }))
        ApiStringView(hint: "Station name", value: stationName, action: { stationName = $0 }, isValid: {_ in true}, width: 200)
      }
      Spacer()
      Text(apiModel.radio?.packet.source.rawValue ?? "")
        .foregroundColor(apiModel.radio?.packet.source == .smartlink ? .green : .blue)
        .font(.title)
        .padding(5)
        .border(.secondary)
        .frame(width: 200)
      Spacer()
      DateTimeView()
    }.frame(height: 40)
      .padding(.horizontal)
  }
}

private struct DateTimeView: View {
  @State var dateTime = "MM/dd/yyyy hh:mm"
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  var formatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = "MM/dd/yyyy hh:mm"
    return formatter
  }
  
  var body: some View {
    
    Text("UTC " + dateTime)
      .onReceive(timer) { _ in
        self.dateTime = formatter.string(from: Date())
      }
      .frame(width: 200)
  }
}

struct PanafallsView_Previews: PreviewProvider {
  static var previews: some View {
    PanafallsView(store: Store(initialState: PanafallsFeature.State(), reducer: PanafallsFeature()),
                  objectModel: ObjectModel())
  }
}
