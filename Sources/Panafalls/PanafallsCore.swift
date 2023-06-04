//
//  PanafallsCore.swift
//  
//
//  Created by Douglas Adams on 5/28/23.
//

import ComposableArchitecture
import Foundation

import FlexApi

public struct PanafallsFeature: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable {
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
  }
}

