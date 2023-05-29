//
//  PanadapterCore.swift
//  
//
//  Created by Douglas Adams on 4/16/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

import FlexApi
import Shared

public struct PanadapterFeature: ReducerProtocol {
  public init() {}

  @Dependency(\.apiModel) var apiModel
  
  public struct State: Equatable {
    
    public init() {}
  }
  
  public enum Action: Equatable {
    case dbLegendDrag(Panadapter, Bool, Int)
    case frequencyLegendDrag(Panadapter, Int)
    case frequencyLinesDrag(Panadapter, Int)
    case panadapterProperty(Panadapter, Panadapter.Property, String)
    case panadapterSize(Panadapter, CGSize)
    case sliceCreate(Panadapter, Int)
    case sliceDrag(Slice, Int)
    case sliceRemove(UInt32)
    case tnfCreate(Int)
    case tnfRemove(UInt32)
    case tnfProperty(Tnf, Tnf.Property, String)
    case tnfsEnable(Bool)
  }
  
  public func reduce(into state: inout State, action: Action) ->  EffectTask<Action> {
    switch action {
      
    case let .panadapterProperty(panadapter, property, value):
      return .run { _ in
        await panadapter.setProperty(property, value)
      }
      
    case let .panadapterSize(panadapter, size):
      return .run { _ in
        
        print("----->>>>> Panadapter width = \(size.width), height = \(size.height))")
        
        await panadapter.setProperty(.xPixels, String(Int(size.width)))
        await panadapter.setProperty(.yPixels, String(Int(size.height)))
      }
      
    case let .dbLegendDrag(panadapter, isUpper, newDbm):
      return .run { _ in
        await panadapter.setProperty(isUpper ? .maxDbm : .minDbm, String(newDbm))
      }

    case let .frequencyLegendDrag(panadapter, newBandwidth):
      return .run { _ in
        await panadapter.setProperty(.bandwidth, newBandwidth.hzToMhz)
      }
    
    case let .frequencyLinesDrag(panadapter, newCenter):
      return .run { _ in
        await panadapter.setProperty(.center, newCenter.hzToMhz)
      }
      
    case let .sliceCreate(panadapter, frequency):
      apiModel.requestSlice(on: panadapter, at: frequency)
      return .none

    case let .sliceDrag(slice, frequency):
      return .run { _ in
        await slice.setProperty(.frequency, frequency.hzToMhz)
      }

    case let .sliceRemove(id):
      apiModel.removeSlice(id)
      return .none

    case let .tnfCreate(frequency):
      apiModel.requestTnf(at: frequency)
      return .none

    case let .tnfProperty(tnf, property, value):
      return .run { _ in
        await tnf.setProperty(property, value)
      }
      
    case let .tnfRemove(id):
      apiModel.removeTnf(id)
      return .none

    case let .tnfsEnable(value):
      return .run { _ in
        await apiModel.radio?.setProperty(.tnfsEnabled , value.as1or0)
      }
    }
  }
}

