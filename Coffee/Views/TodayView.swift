import SwiftUI
import CoreData

struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CoffeeRecordEntity.date, ascending: false),
            NSSortDescriptor(keyPath: \CoffeeRecordEntity.id, ascending: false)
        ],
        animation: .default)
    private var records: FetchedResults<CoffeeRecordEntity>
    
    @Binding var newAmount: String
    @Binding var selectedDate: Date
    @Binding var selectedType: CoffeeTypes
    @Binding var isCafePurchase: Bool
    @Binding var price: String
    
    @State private var swipedItemId: UUID?
    @State private var offset: CGFloat = 0
    @State private var scrollToNewRecord = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var filteredRecords: [CoffeeRecordEntity] {
        records
            .filter { record in
                guard let date = record.date else { return false }
                return Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }
            .sorted { first, second in
                guard let date1 = first.date, let date2 = second.date else { return false }
                if Calendar.current.compare(date1, to: date2, toGranularity: .second) == .orderedSame {
                    return first.id ?? "" > second.id ?? ""
                }
                return date1 > date2
            }
    }
    
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
                        VStack(spacing: 20) {
                            DatePicker(NSLocalizedString("Select_date", comment: ""), selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                                .padding()
                                .background(backgroundColor)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .frame(maxWidth: .infinity)
                            
                            Picker(NSLocalizedString("Coffee_type", comment: ""), selection: $selectedType) {
                                ForEach(CoffeeTypes.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .frame(maxWidth: .infinity)
                            
                            if selectedType == .filter {
                                TextField(NSLocalizedString("Enter_amount", comment: ""), text: $newAmount)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(backgroundColor)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Toggle(NSLocalizedString("Cafe_purchase", comment: ""), isOn: $isCafePurchase)
                                .padding()
                                .background(backgroundColor)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .frame(maxWidth: .infinity)
                            
                            if isCafePurchase {
                                TextField(NSLocalizedString("Enter_price", comment: ""), text: $price)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(backgroundColor)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button(action: {
                                UIApplication.shared.endEditing()
                                addCoffeeRecord()
                            }) {
                                Text(NSLocalizedString("Add_record", comment: ""))
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedType == .filter && newAmount.isEmpty ? Color.gray : Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .disabled(selectedType == .filter && newAmount.isEmpty)
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
                            Text("Žádné záznamy pro vybraný den")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(NSLocalizedString("Coffee_tracker", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func recordView(_ record: CoffeeRecordEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                if let date = record.date {
                    let dateText = "\(NSLocalizedString("Date", comment: "")): \(dateFormatter.string(from: date))"
                    Text(dateText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
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
    
    private func addCoffeeRecord() {
        let amount = selectedType == .espresso ? 30.0 : Double(newAmount) ?? 0.0
        let recordPrice = isCafePurchase ? Double(price) : nil
        
        let entity = CoreDataManager.shared.createRecord()
        entity.uuid = UUID()
        
        // Nastavíme vybrané datum, ale zachováme aktuální čas
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        let currentComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        components.hour = currentComponents.hour
        components.minute = currentComponents.minute
        components.second = currentComponents.second
        entity.date = Calendar.current.date(from: components) ?? Date()
        
        entity.amount = amount
        entity.coffeeType = selectedType
        if let recordPrice = recordPrice {
            entity.price = recordPrice
        }
        
        do {
            try CoreDataManager.shared.saveContext()
            newAmount = ""
            price = ""
            
            // Jemná haptická zpětná vazba pouze po úspěšném přidání
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error saving record: \(error)")
        }
    }
    
    private func deleteRecord(_ record: CoffeeRecordEntity) {
        do {
            try CoreDataManager.shared.deleteRecord(record)
            // Jemná haptická zpětná vazba pouze po úspěšném smazání
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error deleting record: \(error)")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct SwipeToDeleteView<Content: View>: View {
    let record: CoffeeRecordEntity
    let onDelete: () -> Void
    let content: () -> Content
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var isDeleting = false
    
    private let buttonSize: CGFloat = 65
    private let buttonSpacing: CGFloat = 12
    
    var body: some View {
        ZStack(alignment: .trailing) {
            content()
                .frame(maxWidth: .infinity)
                .offset(x: offset)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            if abs(value.translation.width) > abs(value.translation.height) {
                                if !isDeleting {
                                    offset = max(min(value.translation.width, 0), -(buttonSize + buttonSpacing))
                                }
                            }
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > abs(value.translation.height) {
                                let threshold: CGFloat = -50
                                if value.translation.width < threshold {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        offset = -(buttonSize + buttonSpacing)
                                        isSwiped = true
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        offset = 0
                                        isSwiped = false
                                    }
                                }
                            }
                        }
                )
            
            deleteButton
                .offset(x: max(85 + offset, 0))
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: offset)
    }
    
    private var deleteButton: some View {
        Button(action: deleteWithAnimation) {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: buttonSize, height: buttonSize)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                )
        }
        .disabled(isDeleting)
    }
    
    private func deleteWithAnimation() {
        isDeleting = true
        withAnimation(.easeInOut(duration: 0.15)) {
            offset = -UIScreen.main.bounds.width
        }
        onDelete()
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(
            newAmount: .constant(""),
            selectedDate: .constant(Date()),
            selectedType: .constant(.espresso),
            isCafePurchase: .constant(false),
            price: .constant("")
        )
    }
}
