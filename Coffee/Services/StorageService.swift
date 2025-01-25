import Foundation

class StorageService {
    private static let recordsKey = "coffeeRecords"
    private static let amountKey = "newAmount"
    private static let selectedTypeKey = "selectedType"
    private static let isCafePurchaseKey = "isCafePurchase"
    private static let priceKey = "price"
    private static let versionKey = "storageVersion"
    
    private static let currentVersion = 1
    
    static func initialize() {
        let savedVersion = UserDefaults.standard.integer(forKey: versionKey)
        if savedVersion < currentVersion {
            // Vyčistíme stará data při změně verze
            UserDefaults.standard.removeObject(forKey: recordsKey)
            UserDefaults.standard.removeObject(forKey: amountKey)
            UserDefaults.standard.removeObject(forKey: selectedTypeKey)
            UserDefaults.standard.removeObject(forKey: isCafePurchaseKey)
            UserDefaults.standard.removeObject(forKey: priceKey)
            
            // Uložíme novou verzi
            UserDefaults.standard.set(currentVersion, forKey: versionKey)
        }
    }
    
    static func saveRecords(_ records: [CoffeeRecordEntity]) {
        let encoder = JSONEncoder()
        encoder.userInfo[.managedObjectContext] = CoreDataManager.shared.container.viewContext
        if let encoded = try? encoder.encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    static func loadRecords() -> [CoffeeRecordEntity] {
        if let data = UserDefaults.standard.data(forKey: recordsKey) {
            let decoder = JSONDecoder()
            decoder.userInfo[.managedObjectContext] = CoreDataManager.shared.container.viewContext
            if let records = try? decoder.decode([CoffeeRecordEntity].self, from: data) {
                return records
            }
        }
        return []
    }
    
    static func saveFormData(amount: String, type: CoffeeTypes, isCafePurchase: Bool, price: String) {
        UserDefaults.standard.set(amount, forKey: amountKey)
        UserDefaults.standard.set(type.rawValue, forKey: selectedTypeKey)
        UserDefaults.standard.set(isCafePurchase, forKey: isCafePurchaseKey)
        UserDefaults.standard.set(price, forKey: priceKey)
    }
    
    static func loadAmount() -> String {
        UserDefaults.standard.string(forKey: amountKey) ?? ""
    }
    
    static func loadSelectedType() -> CoffeeTypes {
        if let typeString = UserDefaults.standard.string(forKey: selectedTypeKey),
           let type = CoffeeTypes(rawValue: typeString) {
            return type
        }
        return .espresso
    }
    
    static func loadIsCafePurchase() -> Bool {
        UserDefaults.standard.bool(forKey: isCafePurchaseKey)
    }
    
    static func loadPrice() -> String {
        UserDefaults.standard.string(forKey: priceKey) ?? ""
    }
} 
