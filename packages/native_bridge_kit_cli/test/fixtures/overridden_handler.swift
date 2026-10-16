class OverriddenHandler {
    private let methodChannel = FlutterMethodChannel(
        name: "fixture",
        binaryMessenger: messenger
    )
    private let eventChannel = FlutterEventChannel(
        name: "fixture/custom-events",
        binaryMessenger: messenger
    )

    func register() {
        switch call.method {
        case "custom_method":
            handle()
        default:
            break
        }
    }
}
