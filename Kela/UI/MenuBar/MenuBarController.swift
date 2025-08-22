import SwiftUI

struct MenuBarRootView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 8) {
            WhisperBubble(viewModel: viewModel)
        }
        .padding(8)
        .frame(minWidth: 260)
    }
}


