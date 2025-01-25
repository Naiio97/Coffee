import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CoffeeRecordEntity.date, ascending: false)],
        animation: .default)
    private var records: FetchedResults<CoffeeRecordEntity>
    
    @State private var selectedDate = Date()
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground).opacity(0.15) : Color(.white).opacity(0.5)
    }
    
    @State private var showAllRecords = false
    
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
                        if !showAllRecords {
                            DatePicker("Datum", selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                                .background(backgroundColor)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .frame(maxWidth: .infinity)
                        }

                        if !filteredRecords.isEmpty {
                            ForEach(filteredRecords) { record in
                                SwipeToDeleteView(record: record, onDelete: {
                                    deleteRecord(record)
                                }) {
                                    recordView(record)
                                }
                            }
                        } else {
                            Text(showAllRecords ? "Žádné záznamy" : "Žádné záznamy pro vybraný den")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(NSLocalizedString("History", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Dnes") {
                            selectedDate = Date()
                            showAllRecords = false
                        }
                        Button("Včera") {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                            showAllRecords = false
                        }
                        Button(showAllRecords ? "Zobrazit podle dne" : "Zobrazit vše") {
                            showAllRecords.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func recordView(_ record: CoffeeRecordEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                let dateText = "\(NSLocalizedString("Date", comment: "")): \(dateFormatter.string(from: record.date ?? Date()))"
                Text(dateText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                let amountText = "\(NSLocalizedString("Amount", comment: "")): \(String(format: "%.0f", record.amount)) ml"
                Text(amountText)
                    .font(.body)
                
                let typeText = "\(NSLocalizedString("Type", comment: "")): \(record.coffeeType.rawValue)"
                Text(typeText)
                    .font(.body)
                
                if let price = record.price {
                    let priceText = "\(NSLocalizedString("Price", comment: "")): \(String(format: "%.2f", price)) Kč"
                    Text(priceText)
                        .font(.body)
                }
            }
            Spacer()
            Image(systemName: "cup.and.heat.waves")
                .foregroundColor(.accentColor)
                .font(.title)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func deleteRecord(_ record: CoffeeRecordEntity) {
        viewContext.delete(record)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting record: \(error)")
        }
    }

    private var filteredRecords: [CoffeeRecordEntity] {
        let records = if showAllRecords {
            Array(records)
        } else {
            records.filter {
                guard let date = $0.date else { return false }
                return Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .day)
            }
        }
        
        return records.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
} 
