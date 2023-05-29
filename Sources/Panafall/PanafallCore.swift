//
//  PanafallCore.swift
//  
//
//  Created by Douglas Adams on 5/28/23.
//

import ComposableArchitecture

import FlexApi

public struct PanafallFeature: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    var antennaPopover: Bool
    var bandPopover: Bool
    var daxPopover: Bool
    var displayPopover: Bool

    public init
    (
      antennaPopover: Bool = false,
      bandPopover: Bool = false,
      daxPopover: Bool = false,
      displayPopover: Bool = false
    )
    {
      self.antennaPopover = antennaPopover
      self.bandPopover = bandPopover
      self.daxPopover = daxPopover
      self.displayPopover = displayPopover
    }
  }
  
  public enum Action: Equatable {
    case antennaButton
    case zoomButton(Panadapter, Panadapter.ZoomType)
    case bandButton
    case daxButton
    case displayButton
    case panadapterProperty(Panadapter, Panadapter.Property, String)
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
    
    switch action {
      
    case .antennaButton:
      state.antennaPopover.toggle()
      return .none
      
    case .bandButton:
      state.bandPopover.toggle()
      return .none
      
    case .daxButton:
      state.daxPopover.toggle()
      return .none
      
    case .displayButton:
      state.displayPopover.toggle()
      return .none
    
    case let .panadapterProperty(panadapter, property, value):
      return .run { _ in
        await panadapter.setProperty(property, value)
      }
      
    case let .zoomButton(panadapter, type):
      return .run { _ in
        await panadapter.setZoom(type)
      }
    }
  }
}

