import Foundation

/// Reprezentuje typy kávy dostupné v aplikaci
public enum CoffeeTypes: String, CaseIterable, Codable {
    case espresso = "Espresso"
    case filter = "Filter"
} 