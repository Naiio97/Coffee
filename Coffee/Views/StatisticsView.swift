import SwiftUI
import CoreData

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground).opacity(0.15) : Color(.systemBackground).opacity(0.5)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CoffeeRecordEntity.date, ascending: false)],
        animation: .default)
    private var records: FetchedResults<CoffeeRecordEntity>
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground).opacity(0.15) : Color(.white).opacity(0.5)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        statistics
                        ChartView(records: Array(records))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(NSLocalizedString("Statistics", comment: ""))
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var statistics: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Statistiky")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    StatBox(
                        title: "Celkem káv",
                        value: "\(records.count)",
                        icon: "cup.and.saucer.fill"
                    )
                    
                    StatBox(
                        title: "Celkem ml",
                        value: "\(Int(records.reduce(0) { $0 + $1.amount }))",
                        icon: "drop.fill"
                    )
                }
                
                HStack(spacing: 15) {
                    StatBox(
                        title: "Útrata",
                        value: "\(String(format: "%.0f", records.compactMap { $0.price }.reduce(0, +))) Kč",
                        icon: "creditcard.fill"
                    )
                    
                    StatBox(
                        title: "Průměr/den",
                        value: "\(String(format: "%.1f", averagePerDay)) káv",
                        icon: "chart.bar.fill"
                    )
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var averagePerDay: Double {
        guard !records.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldestDate = records.map { $0.date ?? Date() }.min() ?? Date()
        let days = calendar.dateComponents([.day], from: oldestDate, to: Date()).day ?? 1
        return Double(records.count) / Double(max(days, 1))
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
} 