//
//  PanCore.swift
//  
//
//  Created by Douglas Adams on 3/2/23.
//

import Foundation
import ComposableArchitecture

public struct PanFeature: ReducerProtocol {
  
  public init() {}
  
  public struct State: Equatable {
    
    public init() {}
  }
  
  public enum Action: Equatable {
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
    return .none
  }
}
