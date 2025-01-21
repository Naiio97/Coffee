import SwiftUI

struct ContentView: View {
    @State private var coffeeRecords: [CoffeeRecord] = []
    @State private var newAmount: String = ""
    @State private var selectedDate = Date()
    @State private var selectedType: CoffeeType = .espresso
    @State private var isCafePurchase: Bool = false
    @State private var price: String = ""

    var body: some View {
        TabView {
            TodayView(coffeeRecords: $coffeeRecords, newAmount: $newAmount, selectedDate: $selectedDate, selectedType: $selectedType, isCafePurchase: $isCafePurchase, price: $price)
                .tabItem {
                    Label("Dnes", systemImage: "cup.and.saucer.fill")
                }

            HistoryView(coffeeRecords: coffeeRecords)
                .tabItem {
                    Label("Historie", systemImage: "calendar")
                }
        }
        .accentColor(.blue)
    }
}

struct TodayView: View {
    @Binding var coffeeRecords: [CoffeeRecord]
    @Binding var newAmount: String
    @Binding var selectedDate: Date
    @Binding var selectedType: CoffeeType
    @Binding var isCafePurchase: Bool
    @Binding var price: String

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Vyber datum", selection: $selectedDate, displayedComponents: .date)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Picker("Typ kávy", selection: $selectedType) {
                    ForEach(CoffeeType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

                if selectedType == .filter {
                    TextField("Zadej množství kávy (ml)", text: $newAmount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Toggle("Káva v kavárně", isOn: $isCafePurchase)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                if isCafePurchase {
                    TextField("Zadej cenu (Kč)", text: $price)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button(action: addCoffeeRecord) {
                    Text("Přidat záznam")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()

                List(filteredRecords, id: \.date) { record in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Datum: \(record.date, formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Množství: \(String(format: "%.0f", record.amount)) ml")
                            .font(.body)
                        Text("Typ: \(record.type.rawValue)")
                            .font(.body)
                        if let price = record.price {
                            Text("Cena: \(String(format: "%.2f", price)) Kč")
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationTitle("Sledování kávy")
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }

    private func addCoffeeRecord() {
        let amount = selectedType == .espresso ? 30.0 : Double(newAmount) ?? 0.0
        let recordPrice = isCafePurchase ? Double(price) : nil
        let newRecord = CoffeeRecord(date: selectedDate, amount: amount, type: selectedType, price: recordPrice)
        coffeeRecords.append(newRecord)
        newAmount = ""
        price = ""
    }

    private var filteredRecords: [CoffeeRecord] {
        coffeeRecords.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct HistoryView: View {
    var coffeeRecords: [CoffeeRecord]
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Vyber datum", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                List(filteredRecords, id: \.date) { record in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Datum: \(record.date, formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Množství: \(String(format: "%.0f", record.amount)) ml")
                            .font(.body)
                        Text("Typ: \(record.type.rawValue)")
                            .font(.body)
                        if let price = record.price {
                            Text("Cena: \(String(format: "%.2f", price)) Kč")
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationTitle("Historie kávy")
        }
    }

    private var filteredRecords: [CoffeeRecord] {
        coffeeRecords.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
} 