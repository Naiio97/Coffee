import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedTab = 0
    @State private var newAmount: String = ""
    @State private var selectedDate = Date()
    @State private var selectedType: CoffeeTypes = .espresso
    @State private var isCafePurchase: Bool = false
    @State private var price: String = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(
                newAmount: $newAmount,
                selectedDate: $selectedDate,
                selectedType: $selectedType,
                isCafePurchase: $isCafePurchase,
                price: $price
            )
            .tabItem {
                Label(NSLocalizedString("Today", comment: ""), systemImage: "cup.and.saucer")
            }
            .tag(0)
            
            StatisticsView()
            .tabItem {
                Label(NSLocalizedString("Statistics", comment: ""), systemImage: "chart.bar")
            }
            .tag(1)
            
            HistoryView()
            .tabItem {
                Label(NSLocalizedString("History", comment: ""), systemImage: "clock")
            }
            .tag(2)
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithTransparentBackground()
            
            let tabBarScrollEdgeAppearance = UITabBarAppearance()
            tabBarScrollEdgeAppearance.configureWithDefaultBackground()
            tabBarScrollEdgeAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.1)
            tabBarScrollEdgeAppearance.backgroundEffect = UIBlurEffect(style: .regular)
            
            UITabBar.appearance().standardAppearance = tabBarScrollEdgeAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.1)
            navigationBarAppearance.backgroundEffect = UIBlurEffect(style: .regular)
            
            let navigationBarScrollEdgeAppearance = UINavigationBarAppearance()
            navigationBarScrollEdgeAppearance.configureWithTransparentBackground()
            
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarScrollEdgeAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
