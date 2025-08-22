import SwiftUI

@main
struct KelaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Kela", systemImage: appDelegate.menuBarIconName) {
            VStack(alignment: .leading, spacing: 8) {
                MenuBarRootView(viewModel: appDelegate.viewModel)
                Divider()
                HStack {
                    Button(appDelegate.isPaused ? "Resume" : "Pause") { appDelegate.togglePause() }
                    Spacer()
                    Button("Settings…") { appDelegate.openSettings() }
                    Button("Quit") { NSApp.terminate(nil) }
                }
                #if DEBUG
                Divider()
                HStack {
                    Button("Fake Proactive") { appDelegate.viewModel.debugFakeSuggestion() }
                    Button("Fake Error") { appDelegate.viewModel.debugFakeError() }
                    Button("Speak Test") { appDelegate.viewModel.debugSpeakTest() }
                }
                #endif
            }
            .padding(8)
            .frame(width: 360)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(viewModel: appDelegate.viewModel)
                .frame(width: 640, height: 420)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    let viewModel = AppViewModel()
    @Published var isPaused: Bool = false
    @Published var menuBarIconName: String = "dot.circle"

    func applicationDidFinishLaunching(_ notification: Notification) {
        viewModel.onStateIconChange = { [weak self] name in
            DispatchQueue.main.async { self?.menuBarIconName = name }
        }
        viewModel.onWantsSettings = { [weak self] in self?.openSettings() }
        viewModel.start()
    }

    func togglePause() {
        isPaused.toggle()
        viewModel.setPaused(isPaused)
    }

    func openSettings() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }
}

