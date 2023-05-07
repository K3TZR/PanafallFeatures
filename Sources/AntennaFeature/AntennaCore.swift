//
//  AntennaCore.swift
//  ViewFeatures/AntennaFeature
//
//  Created by Douglas Adams on 12/21/22.
//

import Foundation
import ComposableArchitecture

import FlexApi
import Shared

public struct AntennaFeature: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable {
    case panadapterProperty(Panadapter, Panadapter.Property, String)
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
    switch action {
      
    case let .panadapterProperty(panadapter, property, value):
      return .run { _ in
        await panadapter.setProperty(property, value)
      }
    }
  }
}
