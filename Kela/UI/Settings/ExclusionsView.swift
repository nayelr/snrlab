import SwiftUI

struct ExclusionsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var bundleID: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Excluded Apps")
                .font(.title3.weight(.semibold))
            List {
                ForEach(viewModel.exclusions, id: \.self) { id in
                    Text(id)
                }
                .onDelete { indexSet in
                    viewModel.removeExclusions(at: indexSet)
                }
            }
            HStack {
                TextField("Bundle Identifier", text: $bundleID)
                Button("Add") {
                    guard !bundleID.isEmpty else { return }
                    viewModel.addExclusion(bundleID)
                    bundleID = ""
                }
            }
        }
        .padding()
    }
}


