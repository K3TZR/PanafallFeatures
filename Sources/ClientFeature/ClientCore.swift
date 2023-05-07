//
//  ClientCore.swift
//  ViewFeatures/ClientFeature
//
//  Created by Douglas Adams on 1/19/22.
//

import Foundation
import ComposableArchitecture

import Shared

public struct ClientFeature: ReducerProtocol {
  
  public init() {}
  
  public struct State: Equatable {
    var selection: Pickable
    var stations: [String]
    var handles: [UInt32?]
    var heading: String

    public init
    (
      selection: Pickable,
      stations: [String],
      handles: [UInt32?],
      heading: String = "Choose an action"
    )
    {
      self.selection = selection
      self.stations = stations
      self.handles = handles
      self.heading = heading
    }
  }
  
  public enum Action: Equatable {
    case cancelButton
    case connect(Pickable, UInt32?)
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
    return .none
  }
}
