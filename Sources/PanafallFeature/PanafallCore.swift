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
    public var dbmSpacing: CGFloat
    
    public init(dbmSpacing: CGFloat = 10) {
      self.dbmSpacing = dbmSpacing
    }
  }
  
  public enum Action: Equatable {
    case dbLegendDrag(Panadapter, Bool, Int)
    case dbLegendSpacing(CGFloat)
    case frequencyLegendDrag(Panadapter, Int)
    case frequencyLinesDrag(Panadapter, Int)
    case panadapterProperty(Panadapter, Panadapter.Property, String)
    case sliceCreate
    case tnfCreate
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

    case let .dbLegendSpacing(newSpacing):
      state.dbmSpacing = newSpacing
      return .none

    case let .frequencyLegendDrag(panadapter, newBandwidth):
      return .run { _ in
        await panadapter.setProperty(.bandwidth, newBandwidth.hzToMhz)
      }
    case let .frequencyLinesDrag(panadapter, newCenter):
      return .run { _ in
        await panadapter.setProperty(.center, newCenter.hzToMhz)
      }
      
    case .sliceCreate:
      
      // FIXME:
      
      return .none

    case .tnfCreate:
      
      // FIXME:
      
      return .none
    }
  }
}

