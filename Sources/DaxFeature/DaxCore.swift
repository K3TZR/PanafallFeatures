//
//  DaxCore.swift
//  ViewFeatures/DaxFeature
//
//  Created by Douglas Adams on 12/21/22.
//

import ComposableArchitecture
import Foundation

import FlexApi
import Shared

public struct DaxFeature: ReducerProtocol {
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
