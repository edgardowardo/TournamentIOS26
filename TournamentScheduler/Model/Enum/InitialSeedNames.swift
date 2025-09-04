
enum InitialSeedNames {
    case footballers, seededNumbers
    
    var names: [String] {
        switch self {
        case .footballers:
            return [ "Ryan", "Danny", "Marco", "Miguel", "Manuel", "Ben", "Jak", "John", "Marcos", "Mikel", "Kylian", "Sadio", "Harry", "Erling", "Mohamed", "Elyounoussi", "Thibaut", "Pierre-Emerick", "Virgil", "Luka", "Mario", "Bukayo", "Neymar", "Declan", "Mané", "Christiano", "Lionel", "Kevin", "Patrick", "Max", "Rory", "Bret"]
        case .seededNumbers:
            return (1...32).map { "Seed \($0)" }
        }
    }
    
    func pickRandomNames(_ count: Int) -> [String] {
        guard self != .seededNumbers else { return Array(self.names.prefix(count)) }
        let shuffled = self.names.shuffled()
        return Array(shuffled.prefix(count))
    }
}
