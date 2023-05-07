//
//  PanafallCore.swift
//  
//
//  Created by Douglas Adams on 4/16/23.
//

import ComposableArchitecture
import Foundation

import FlexApi
import Shared
import SwiftUI

public struct PanafallFeature: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable {
    case dbLegendDrag(Panadapter, Bool, Int)
    case panadapterProperty(Panadapter, Panadapter.Property, String)
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
    switch action {
      
    case let .panadapterProperty(panadapter, property, value):
      return .run { _ in
        await panadapter.setProperty(property, value)
      }
      
    case let .dbLegendDrag(panadapter, isUpper, newDbm):
      return .run { _ in
        await panadapter.setProperty(isUpper ? .maxDbm : .minDbm, String(newDbm))
      }
    }
  }
}

