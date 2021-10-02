//
//  ContentView.swift
//  macos-audio-speaker-practice
//
//  Created by soudegesu on 2021/10/02.
//

import SwiftUI

struct ContentView: View {
  
    let presenter = ContentPresenter()
  
    @ViewBuilder var body: some View {
      let devices = presenter.getOutputDevices()
      VStack(alignment: .leading) {
        Text(verbatim: "Output Devices")
        Divider()
        if let outputDevices = devices {
          VStack(alignment: .leading) {
            ForEach(outputDevices.sorted(by: >), id: \.key) { key, value in
              Text(verbatim: "DeviceId:\(key), Name:\(value)")
            }
          }
        } else {
          Text("No output devices")
        }
      }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
