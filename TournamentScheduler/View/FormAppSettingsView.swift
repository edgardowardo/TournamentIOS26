import SwiftUI

struct FormAppSettingsView: View {

    @AppStorage("PoolDetailView.roundsPicker") private var roundsPicker: RoundsPicker = .horizontal
    @AppStorage(SeedNames.userDefaultsKey) private var seedNames: SeedNames = .mixed

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("Pool"),
                    footer: Text("")
                ) {
                    
                    Picker("Seed names", selection: $seedNames) {
                        ForEach(SeedNames.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(.menu)

                    VStack(alignment: .leading) {
                        Text("Rounds picker")
                        Picker("Rounds picker", selection: $roundsPicker) {
                            ForEach(RoundsPicker.allCases, id: \.self) {
                                Text($0.rawValue.capitalized).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension FormAppSettingsView {
    enum RoundsPicker: String, CaseIterable {
        case horizontal, vertical
    }
}


#Preview {
    FormAppSettingsView()
}
