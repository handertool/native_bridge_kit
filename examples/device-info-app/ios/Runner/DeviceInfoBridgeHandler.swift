import Flutter
import UIKit

/// Runtime registration for the DeviceInfoBridge contract.
final class DeviceInfoBridgeHandler: NSObject, FlutterStreamHandler {
  private let methodChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel
  private var eventSink: FlutterEventSink?
  private var batteryTimer: Timer?

  init(binaryMessenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: "device_info",
      binaryMessenger: binaryMessenger
    )
    eventChannel = FlutterEventChannel(
      name: "device_info/battery_level",
      binaryMessenger: binaryMessenger
    )
    super.init()
  }

  func register() {
    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard self != nil else {
        result(FlutterError(code: "HANDLER_UNAVAILABLE", message: nil, details: nil))
        return
      }

      switch call.method {
      case "get_model":
        result(UIDevice.current.model)
      case "get_os_version":
        result(UIDevice.current.systemVersion)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    eventChannel.setStreamHandler(self)
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    UIDevice.current.isBatteryMonitoringEnabled = true
    eventSink = events
    batteryTimer?.invalidate()
    emitBatteryLevel()
    batteryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
      self?.emitBatteryLevel()
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    batteryTimer?.invalidate()
    batteryTimer = nil
    eventSink = nil
    return nil
  }

  private func emitBatteryLevel() {
    let rawLevel = UIDevice.current.batteryLevel
    let level = max(0.0, min(100.0, Double(rawLevel) * 100.0))
    eventSink?(level)
  }
}
