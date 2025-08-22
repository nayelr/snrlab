import SwiftUI

struct HotkeysView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var useFn: Bool = true

    var body: some View {
        Form {
            Toggle("Push-to-talk with Fn (hold)", isOn: $useFn)
                .onChange(of: useFn) { _, new in
                    viewModel.hotkey.setMode(new ? .fn : .command)
                }
            Toggle("Start at login", isOn: $viewModel.startAtLogin)
        }
        .padding()
    }
}

