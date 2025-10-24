import AppIntents

struct SOSImmediateIntent: AppIntent {
    static var title: LocalizedStringResource = "Send SOS"
    static var description = IntentDescription(
        "Prepare an SOS message with your location and open the app for confirmation."
    )

    @Parameter(title: "Note", default: "SOS via Siri")
    var note: String

    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        SMSShareCoordinator.shared.queueLocalSMS(note: note)
        return .result()
    }
}

struct SOSShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .red

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SOSImmediateIntent(),
            phrases: [
                "Send SOS in \(.applicationName)",
                "Emergency in \(.applicationName)",
                "Help in \(.applicationName)"
            ],
            shortTitle: "SOS",
            systemImageName: "exclamationmark.triangle.fill"
        )
    }
}
