import SwiftUI

struct FormAppSettingsView: View {

    @AppStorage(SeedNames.userDefaultsKey) private var seedNames: SeedNames = .mixed
    @AppStorage(FormPoolView.keySeedControlStyle) private var seedControlStyle: SeedControlStyle = .button
    @AppStorage(PoolDetailView.keyRoundsPicker) private var roundsPicker: RoundsPicker = .horizontal
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("Edit Pool"),
                    footer: Text("")
                ) {
                    
                    Picker("Seed names", selection: $seedNames) {
                        ForEach(SeedNames.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    VStack(alignment: .leading) {
                        Text("Seed control style")
                        Picker("Seed control style", selection: $seedControlStyle) {
                            ForEach(SeedControlStyle.allCases, id: \.self) {
                                Text($0.rawValue.capitalized).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section(
                    header: Text("Matches"),
                    footer: Text("")
                ) {

                    VStack(alignment: .leading) {
                        Text("Rounds filter")
                        Picker("Rounds filter", selection: $roundsPicker) {
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

enum SeedControlStyle: String, CaseIterable {
    case button, toggle
}

#Preview {
    FormAppSettingsView()
}
