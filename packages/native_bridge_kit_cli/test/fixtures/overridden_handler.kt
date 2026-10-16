class OverriddenHandler {
    private val methodChannel = MethodChannel()
    private val eventChannel = EventChannel(
        messenger,
        "fixture/custom-events",
    )

    fun register() {
        when (call.method) {
            "custom_method" -> handle()
        }
    }
}
