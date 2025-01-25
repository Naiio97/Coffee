import CoreData
import Foundation

@objc(CoffeeRecordEntity)
public class CoffeeRecordEntity: NSManagedObject, Codable, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var amount: Double
    @NSManaged public var type: String?
    @NSManaged private var primitivePrice: NSNumber?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case amount
        case type
        case price
    }
    
    // UUID konverze
    public var uuid: UUID {
        get {
            UUID(uuidString: id ?? "") ?? UUID()
        }
        set {
            id = newValue.uuidString
        }
    }
    
    var coffeeType: CoffeeTypes {
        get {
            CoffeeTypes(rawValue: type ?? "") ?? .espresso
        }
        set {
            type = newValue.rawValue
        }
    }
    
    // Price konverze
    public var price: Double? {
        get {
            primitivePrice?.doubleValue
        }
        set {
            primitivePrice = newValue as NSNumber?
        }
    }
    
    // Implementace Codable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(amount, forKey: .amount)
        try container.encode(coffeeType, forKey: .type)
        try container.encode(price, forKey: .price)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Chybí managed object context"))
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        amount = try container.decode(Double.self, forKey: .amount)
        coffeeType = try container.decode(CoffeeTypes.self, forKey: .type)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

extension CoffeeRecordEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoffeeRecordEntity> {
        return NSFetchRequest<CoffeeRecordEntity>(entityName: "CoffeeRecordEntity")
    }
} 