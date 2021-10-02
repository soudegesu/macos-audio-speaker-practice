//
//  ContentPresenter.swift
//  macos-audio-speaker-practice
//
//  Created by soudegesu on 2021/10/02.
//

import Foundation
import AudioToolbox

class ContentPresenter {

  func getOutputDevices() -> [AudioDeviceID: String]? {
      var result: [AudioDeviceID: String] = [:]
      let devices = getAllDevices()
      
      for device in devices {
          if isOutputDevice(deviceID: device) {
              result[device] = getDeviceName(deviceID: device)
          }
      }
      
      return result
  }
  
  private func isOutputDevice(deviceID: AudioDeviceID) -> Bool {
      var propertySize: UInt32 = 256
      
      var propertyAddress = AudioObjectPropertyAddress(
          mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
          mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
      
      _ = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
      
      return propertySize > 0
  }
  
  private func getDeviceName(deviceID: AudioDeviceID) -> String {
      var propertySize = UInt32(MemoryLayout<CFString>.size)
      
      var propertyAddress = AudioObjectPropertyAddress(
          mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
          mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
      
      var result: CFString = "" as CFString
      
      AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &result)
      
      return result as String
  }
  
  private func getAllDevices() -> [AudioDeviceID] {
      let devicesCount = getNumberOfDevices()
      var devices = [AudioDeviceID](repeating: 0, count: Int(devicesCount))
      
      var propertyAddress = AudioObjectPropertyAddress(
          mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
          mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
      
      var devicesSize = devicesCount * UInt32(MemoryLayout<UInt32>.size)
      
      AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &devicesSize, &devices)
      
      return devices
  }
  
  private func getNumberOfDevices() -> UInt32 {
      var propertySize: UInt32 = 0
      
      var propertyAddress = AudioObjectPropertyAddress(
          mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
          mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
      
      _ = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
      
      return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
  }
}

