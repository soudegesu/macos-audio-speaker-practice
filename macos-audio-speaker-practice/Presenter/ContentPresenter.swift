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
  
  func getDeviceVolume(deviceID: AudioDeviceID) -> [Float] {
      let channelsCount = 2
      var channels = [UInt32](repeating: 0, count: channelsCount)
      var propertySize = UInt32(MemoryLayout<UInt32>.size * channelsCount)
      var leftLevel = Float32(-1)
      var rigthLevel = Float32(-1)
      
      var propertyAddress = AudioObjectPropertyAddress(
          mSelector: AudioObjectPropertySelector(kAudioDevicePropertyPreferredChannelsForStereo),
          mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
      
      let status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &channels)
      
      if status != noErr { return [-1] }
      
      propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
      propertySize = UInt32(MemoryLayout<Float32>.size)
      propertyAddress.mElement = channels[0]
      
      AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &leftLevel)
      
      propertyAddress.mElement = channels[1]
      
      AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &rigthLevel)
      
      return [leftLevel, rigthLevel]
  }
  
  func setDeviceVolume(deviceID: AudioDeviceID, leftChannelLevel: Float, rightChannelLevel: Float) {
      let channelsCount = 2
      var channels = [UInt32](repeating: 0, count: channelsCount)
      var propertySize = UInt32(MemoryLayout<UInt32>.size * channelsCount)
      var leftLevel = leftChannelLevel
      var rigthLevel = rightChannelLevel
      
      var propertyAddress = AudioObjectPropertyAddress(
          mSelector: AudioObjectPropertySelector(kAudioDevicePropertyPreferredChannelsForStereo),
          mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
      
      let status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &channels)
      
      if status != noErr { return }
      
      propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
      propertySize = UInt32(MemoryLayout<Float32>.size)
      propertyAddress.mElement = channels[0]
      
      AudioObjectSetPropertyData(deviceID, &propertyAddress, 0, nil, propertySize, &leftLevel)
      
      propertyAddress.mElement = channels[1]
      
      AudioObjectSetPropertyData(deviceID, &propertyAddress, 0, nil, propertySize, &rigthLevel)
  }
  
  func getDefaultOutputDevice() -> AudioDeviceID {
          var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
          var deviceID = kAudioDeviceUnknown
          
          var propertyAddress = AudioObjectPropertyAddress(
              mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
              mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
              mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
          
          AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceID)
          
          return deviceID
      }
}

