import SwiftUI
import CoreData

/// Hlavní vstupní bod aplikace
@main
struct CoffeeTrackerApp: App {
    // Držíme silnou referenci na CoreDataManager
    let persistenceController: CoreDataManager
    
    init() {
        // Inicializujeme CoreDataManager při startu aplikace
        persistenceController = CoreDataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Inicializujeme úložiště při prvním spuštění
                    StorageService.initialize()
                }
        }
    }
} 