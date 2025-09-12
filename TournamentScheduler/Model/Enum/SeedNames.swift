
import Foundation

enum SeedNames: String, CaseIterable {
    case boys, girls, mixed, numbers
    
    var names: [String] {
        switch self {
        case .boys:
            return boyNames
        case .girls:
            return girlNames
        case .mixed:
            return (boyNames + girlNames).shuffled()
        case .numbers:
            return (1...64).map { "Seed \($0)" }
        }
    }
        
    func pickRandomNames(_ count: Int) -> [String] {
        guard self != .numbers else { return Array(self.names.prefix(count)) }
        let shuffled = self.names.shuffled()
        return Array(shuffled.prefix(count))
    }
}

extension SeedNames {
    static var userDefaultsKey: String { "FormPoolView.seedNames" }
}

private let boyNames = [
    "Aaron",
    "Adam",
    "Aiden",
    "Alex",
    "Andre",
    "Andy",
    "Angel",
    "Ben",
    "Blake",
    "Brian",
    "Caleb",
    "Carl",
    "Carter",
    "Chris",
    "Cody",
    "Colin",
    "Connor",
    "Craig",
    "David",
    "Derek",
    "Dylan",
    "Eli",
    "Elias",
    "Elijah",
    "Ethan",
    "Evan",
    "Felix",
    "Frank",
    "Gavin",
    "Grant",
    "Henry",
    "Isaac",
    "Ian",
    "Jack",
    "Jacob",
    "Jake",
    "James",
    "Jason",
    "Jayden",
    "Jesse",
    "Joel",
    "John",
    "Jonah",
    "Jordan",
    "Jose",
    "Joseph",
    "Josh",
    "Julian",
    "Justin",
    "Kevin",
    "Kyle",
    "Liam",
    "Logan",
    "Louis",
    "Luke",
    "Mason",
    "Max",
    "Micah",
    "Miles",
    "Nathan",
    "Noah",
    "Oscar",
    "Ryan",
    "Sam"
]

private let girlNames = [
    "Abby",
    "Ada",
    "Adele",
    "Alexa",
    "Alice",
    "Amber",
    "Amelia",
    "Amy",
    "Anna",
    "Annie",
    "April",
    "Aria",
    "Ariel",
    "Ava",
    "Bella",
    "Beth",
    "Briana",
    "Brooke",
    "Carla",
    "Carmen",
    "Casey",
    "Chloe",
    "Clara",
    "Daisy",
    "Dana",
    "Diane",
    "Donna",
    "Eden",
    "Edith",
    "Elena",
    "Eliza",
    "Ella",
    "Ellie",
    "Elsie",
    "Emery",
    "Emma",
    "Erika",
    "Esme",
    "Faith",
    "Fiona",
    "Flora",
    "Freya",
    "Gina",
    "Grace",
    "Gwen",
    "Hailey",
    "Hannah",
    "Hazel",
    "Holly",
    "Irene",
    "Iris",
    "Isla",
    "Ivy",
    "Jade",
    "Jamie",
    "Jenna",
    "Jessie",
    "Julia",
    "June",
    "Kara",
    "Katie",
    "Kayla",
    "Kylie",
    "Laura"
]
