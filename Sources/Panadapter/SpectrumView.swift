//
//  SpectrumView.swift
//  
//
//  Created by Douglas Adams on 5/26/23.
//

import SwiftUI

import FlexApi
import Shared

/*
 // ----------------------------------------------------------------------------
 // MARK: - PanadapterFrame Public properties
 
 public var intensities = [UInt16](repeating: 0, count: kMaxBins) // Array of bin values
 public var binSize = 0                                           // Bin size in bytes
 public var frameNumber = 0                                       // Frame number
 public var segmentStart = 0                                      // first bin in this segment
 public var segmentSize = 0                                       // number of bins in this segment
 public var frameSize = 0                                         // number of bins in the complete frame
 */

public enum SpectrumType: String {
  case line
  case fill
  case gradient
}

struct SpectrumView: View {
  @ObservedObject var panadapterStream: PanadapterStream
//  let size: CGSize

  @AppStorage("spectrumColor") var spectrumColor = DefaultColors.spectrumColor
  @AppStorage("spectrumFillColor") var spectrumFillColor = DefaultColors.spectrumFillColor
  @AppStorage("spectrumFillLevel") var spectrumFillLevel: Double = 0
  @AppStorage("spectrumGradient") var spectrumGradient: Bool = true
  @AppStorage("spectrumType") var spectrumType: String = SpectrumType.fill.rawValue
  
  var body: some View {
    ZStack {
      if let frame = panadapterStream.panadapterFrame {
        switch spectrumType {
        case SpectrumType.gradient.rawValue:
          LinearGradient(gradient: Gradient(stops: SpectrumGradient().stops ), startPoint: .bottom, endPoint: .top)
            .clipShape(SpectrumShape(frame: frame, closed: true))  // << !!
          SpectrumShape(frame: frame)
            .stroke(spectrumColor)
          
        case SpectrumType.fill.rawValue:
          Rectangle()
            .fill(spectrumFillColor.opacity(spectrumFillLevel / 100))
            .clipShape(SpectrumShape(frame: frame, closed: true))
          SpectrumShape(frame: frame)
            .stroke(spectrumColor)
          
        default:
          SpectrumShape(frame: frame)
            .stroke(spectrumColor)
        }
      }
    }
  }
}

struct SpectrumShape: Shape {
  let frame: PanadapterFrame

  var closed = false
  
  func path(in rect: CGRect) -> Path {
    
    return Path { p in
      var x: CGFloat = rect.minX
      var y: CGFloat = CGFloat(frame.intensities[0])
      p.move(to: CGPoint(x: x, y: y))

      for i in 1..<frame.frameSize {
        y = CGFloat(frame.intensities[i])
        x += rect.width / CGFloat(frame.frameSize - 1)
        p.addLine(to: CGPoint(x: x, y: y ))
      }
      if closed {
          p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
          p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
          p.closeSubpath()
      }
    }
  }
}

//struct SpectrumView_Previews: PreviewProvider {
//  static var previews: some View {
//    SpectrumView(frame: PanadapterFrame(128) )
//  }
//}
