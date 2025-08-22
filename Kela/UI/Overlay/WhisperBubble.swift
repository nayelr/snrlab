import SwiftUI

struct WhisperBubble: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var scale: CGFloat = 0.98

    var body: some View {
        if viewModel.showBubble {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.title3.weight(.semibold))
                    Spacer()
                    if viewModel.state == .thinking {
                        ProgressView().controlSize(.small)
                    }
                }
                .padding(.top, 6)

                if viewModel.state == .listening {
                    Waveform(level: viewModel.micLevel)
                        .frame(height: 26)
                        .animation(.easeOut(duration: 0.12), value: viewModel.micLevel)
                }

                if !viewModel.transcriptText.isEmpty {
                    Text(viewModel.transcriptText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Text(viewModel.bubbleText)
                    .font(.body)
                    .textSelection(.enabled)

                HStack {
                    Button("OK") { withAnimation(.spring(response: 0.2)) { viewModel.showBubble = false } }
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent)
                    Button("Dismiss") { withAnimation(.easeOut(duration: 0.12)) { viewModel.showBubble = false } }
                        .keyboardShortcut(.cancelAction)
                        .buttonStyle(.bordered)
                }
                .padding(.bottom, 6)
            }
            .padding(12)
            .background(GlassBackground())
            .scaleEffect(scale)
            .onAppear { withAnimation(.spring(response: 0.2)) { scale = 1.0 } }
            .transition(.scale.combined(with: .opacity))
        }
    }

    private var title: String {
        switch viewModel.state {
        case .idle: return "Kela"
        case .listening: return "Listening"
        case .thinking: return "Thinking"
        case .alert: return "Notice"
        }
    }
}

struct Waveform: View {
    var level: Float
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let bars = Int(width / 6)
            HStack(spacing: 3) {
                ForEach(0..<bars, id: \.self) { i in
                    let h = CGFloat(max(2, CGFloat(level) * 40 * noise(i)))
                    Capsule().fill(.primary.opacity(0.6)).frame(width: 3, height: h)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    private func noise(_ i: Int) -> CGFloat { CGFloat((sin(Double(i) * 0.35) + 1.3) / 2.3) }
}

