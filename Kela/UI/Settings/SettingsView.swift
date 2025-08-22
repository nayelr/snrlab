import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        TabView {
            HotkeysView(viewModel: viewModel)
                .tabItem { Label("General", systemImage: "gear") }
            ExclusionsView(viewModel: viewModel)
                .tabItem { Label("Exclusions", systemImage: "nosign") }
            AppearanceView(viewModel: viewModel)
                .tabItem { Label("Appearance", systemImage: "sparkles") }
            VoiceView(viewModel: viewModel)
                .tabItem { Label("Voice", systemImage: "waveform") }
        }
        .padding()
    }
}

struct AppearanceView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var glassIntensity: Double = 0.6
    @State private var compact: Bool = false
    var body: some View {
        Form {
            Toggle("Compact size", isOn: $compact)
            Slider(value: $glassIntensity, in: 0...1) { Text("Glass intensity") }
            Button("Repair Permissions") { PermissionsManager.repair() }
        }
    }
}

struct VoiceView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var modelPath: String = ""
    @State private var ttsVoice: String = "com.apple.voice.compact.en-US.Samantha"
    var body: some View {
        Form {
            TextField("ASR Model Path", text: $modelPath)
            TextField("TTS Voice Identifier", text: $ttsVoice)
            Button("Test Speak") { viewModel.tts.speak("Hello from Kela") }
        }
    }
}


