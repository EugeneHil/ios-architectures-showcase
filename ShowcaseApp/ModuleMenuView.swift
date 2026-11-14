import SwiftUI

struct ModuleMenuView: View {
    let repository: any TodoRepository

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(ModuleRegistry.modules.enumerated()), id: \.offset) { _, module in
                    NavigationLink {
                        ModuleScreen(module: module, repository: repository)
                    } label: {
                        ModuleRow(meta: module.meta)
                    }
                }
            }
            .navigationTitle("Architectures")
        }
    }
}

private struct ModuleRow: View {
    let meta: ArchitectureMeta

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(meta.name)
                    .font(.headline)
                Spacer()
                Text(meta.status.symbol)
                Text(meta.ui.rawValue)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())
            }
            Text(meta.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
