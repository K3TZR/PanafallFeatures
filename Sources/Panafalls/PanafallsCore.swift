//
//  PanafallsCore.swift
//  
//
//  Created by Douglas Adams on 5/28/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

import FlexApi
import OpusPlayer
import Shared
import XCGWrapper

public struct PanafallsFeature: ReducerProtocol {
  public init() {}

  @Dependency(\.apiModel) var apiModel
  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel

  public struct State: Equatable {
    var markers: Bool
    var rxAudio: Bool
    var txAudio: Bool
    var opusPlayer: OpusPlayer? = nil

    public init(
      markers: Bool = UserDefaults.standard.bool(forKey: "markers"),
      rxAudio: Bool = UserDefaults.standard.bool(forKey: "rxAudio"),
      txAudio: Bool = UserDefaults.standard.bool(forKey: "txAudio")
    )
    {
      self.markers = markers
      self.rxAudio = rxAudio
      self.txAudio = txAudio
    }
  }
  
  public enum Action: Equatable {
    case cwxButton(Bool)
    case fdxButton(Bool)
    case headphoneGain(Int)
    case headphoneMute(Bool)
    case lineoutGain(Int)
    case lineoutMute(Bool)
    case markerButton(Bool)
    case panadapterButton
    case panelButton
    case rxAudioButton(Bool)
    case tnfButton(Bool)
    case txAudioButton(Bool)
   }
  
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      // Parent logic
      switch action {
        
      case let .cwxButton(boolValue):     // FIXME:
        print("cwxButton = \(boolValue) // FIXME:")
        return .none
        
      case let .fdxButton(boolValue):
        return .run {_ in
          await apiModel.radio?.setProperty(.fullDuplexEnabled, boolValue.as1or0)
        }

      case let .headphoneGain(intValue):
        return .run {_ in
          await apiModel.radio?.setProperty(.headphonegain, String(intValue))
        }

      case let .headphoneMute(boolValue):
        return .run {_ in
          await apiModel.radio?.setProperty(.headphoneMute, boolValue.as1or0)
        }

      case let .lineoutGain(intValue):
        return .run {_ in
          await apiModel.radio?.setProperty(.lineoutgain, String(intValue))
        }
        
      case let .lineoutMute(boolValue):
        return .run {_ in
          await apiModel.radio?.setProperty(.lineoutMute, boolValue.as1or0)
        }

      case let .markerButton(boolValue):        // FIXME:
        print("markerButton = \(boolValue) // FIXME:")
        return .none
        
      case .panadapterButton:
         apiModel.requestPanadapter()
         return .none
         
      case .panelButton:        // FIXME:
        print("panelButton // FIXME:")
        return .none

       case let .rxAudioButton(boolValue):
         state.rxAudio = boolValue
         if apiModel.radio != nil {
           // CONNECTED, start / stop RxAudio
           if state.rxAudio {
             return startRxAudio(&state, apiModel, streamModel)
           } else {
             return stopRxAudio(&state, objectModel, streamModel)
           }
         } else {
           // NOT CONNECTED
           return .none
         }
         
      case let .tnfButton(boolValue):
        return .run {_ in
          await apiModel.radio?.setProperty(.tnfsEnabled, boolValue.as1or0)
        }
        
      case let .txAudioButton(boolValue):       // FIXME:
        print("txAudioButton = \(boolValue) // FIXME:")
        return .none
      }
    }
  }
}

private func startRxAudio(_ state: inout PanafallsFeature.State, _ apiModel: ApiModel, _ streamModel: StreamModel) ->  EffectTask<PanafallsFeature.Action> {
  if state.opusPlayer == nil {
    // ----- START Rx AUDIO -----
    state.opusPlayer = OpusPlayer()
    // start audio
    return .fireAndForget { [state] in
      // request a stream
      if let id = try await apiModel.requestRemoteRxAudioStream().streamId {
        // finish audio setup
        state.opusPlayer?.start(id: id)
        streamModel.remoteRxAudioStreams[id: id]?.delegate = state.opusPlayer
      }
    }
  }
  return .none
}

private func stopRxAudio(_ state: inout PanafallsFeature.State, _ objectModel: ObjectModel, _ streamModel: StreamModel) ->  EffectTask<PanafallsFeature.Action> {
  if state.opusPlayer != nil {
    // ----- STOP Rx AUDIO -----
    state.opusPlayer!.stop()
    let id = state.opusPlayer!.id
    state.opusPlayer = nil
    return .run { _ in
      await streamModel.sendRemoveStream(id)
    }
  }
  return .none
}


