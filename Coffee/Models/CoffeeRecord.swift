import Foundation

enum CoffeeType: String, CaseIterable {
    case espresso = "Espresso"
    case filter = "Filter"
}

struct CoffeeRecord {
    var date: Date
    var amount: Double // množství kávy v mililitrech
    var type: CoffeeType // typ kávy
    var price: Double? // cena kávy, pokud byla zakoupena v kavárně
} 