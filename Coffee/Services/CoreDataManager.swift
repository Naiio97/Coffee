import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "CoffeeModel")
        
        // Pokus o načtení úložiště
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                
                // Pokus o vymazání starého úložiště
                self.deletePersistentStore()
                
                // Znovu načtení úložiště
                self.container.loadPersistentStores { description, error in
                    if let error = error {
                        print("Core Data failed to load after store deletion: \(error.localizedDescription)")
                        fatalError("Core Data store failed to load: \(error.localizedDescription)")
                    }
                    
                    // Nastavení merge policy pro řešení konfliktů
                    self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    self.container.viewContext.automaticallyMergesChangesFromParent = true
                    
                    // Nastavení pro lepší výkon
                    self.container.viewContext.shouldDeleteInaccessibleFaults = true
                    
                    // Nastavení pro lepší konzistenci dat
                    self.container.viewContext.name = "viewContext"
                    self.container.viewContext.transactionAuthor = "app"
                    self.container.viewContext.retainsRegisteredObjects = true
                }
                return
            }
            
            // Nastavení merge policy pro řešení konfliktů
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            
            // Nastavení pro lepší výkon
            self.container.viewContext.shouldDeleteInaccessibleFaults = true
            
            // Nastavení pro lepší konzistenci dat
            self.container.viewContext.name = "viewContext"
            self.container.viewContext.transactionAuthor = "app"
            self.container.viewContext.retainsRegisteredObjects = true
        }
    }
    
    private func deletePersistentStore() {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else { return }
        
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            print("Successfully deleted persistent store")
        } catch {
            print("Failed to delete persistent store: \(error)")
        }
    }
    
    func saveContext() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    func createRecord() -> CoffeeRecordEntity {
        return CoffeeRecordEntity(context: container.viewContext)
    }
    
    func addRecord(_ record: CoffeeRecordEntity) throws {
        let entity = CoffeeRecordEntity(context: container.viewContext)
        entity.uuid = UUID()
        entity.date = record.date
        entity.amount = record.amount
        entity.coffeeType = record.coffeeType
        entity.price = record.price
        
        try saveContext()
    }
    
    func fetchRecords() -> [CoffeeRecordEntity] {
        let request = NSFetchRequest<CoffeeRecordEntity>(entityName: "CoffeeRecordEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CoffeeRecordEntity.date, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching records: \(error)")
            return []
        }
    }
    
    func deleteRecord(_ record: CoffeeRecordEntity) throws {
        container.viewContext.delete(record)
        try saveContext()
    }
} 
