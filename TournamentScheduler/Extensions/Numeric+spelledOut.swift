import Foundation

extension NumberFormatter {
    static let spelled: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()
}

extension Numeric {
    var spelledOut: String? { NumberFormatter.spelled.string(for: self) }
}
