//
//  DisplayCore.swift
//  ViewFeatures/DisplayFeature
//
//  Created by Douglas Adams on 12/21/22.
//

import Foundation
import ComposableArchitecture

import FlexApi
import Shared

public struct DisplayFeature: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var panadapterId: UInt32?
    public var waterfallId: UInt32?
    
    public init(panadapterId: UInt32?, waterfallId: UInt32?) {
      self.panadapterId = panadapterId
      self.waterfallId = waterfallId
    }
  }
  
  public enum Action: Equatable {
    case panadapterProperty(Panadapter, Panadapter.Property, String)
    case waterfallProperty(Waterfall, Waterfall.Property, String)
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
    switch action {
      
    case let .panadapterProperty(panadapter, property, stringValue):
      return .run { _ in
        await panadapter.setProperty(property, stringValue)
      }

    case let .waterfallProperty(waterfall, property, stringValue):
      return .run { _ in
        await waterfall.setProperty(property, stringValue)
      }
    }
  }
}
