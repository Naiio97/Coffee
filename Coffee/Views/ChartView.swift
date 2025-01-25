import SwiftUI
import Charts

struct ChartView: View {
    let records: [CoffeeRecordEntity]
    @State private var selectedPeriod: ChartPeriodType = .week
    @State private var selectedDataPoint: ChartDataPoint?
    
    @Environment(\.colorScheme) private var colorScheme
    
    enum ChartPeriodType {
        case week, month, year
        
        var title: String {
            switch self {
            case .week: return "Týden"
            case .month: return "Měsíc"
            case .year: return "Rok"
            }
        }
    }
    
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Double
        let type: String
    }
    
    struct CoffeeTypeDataPoint: Identifiable {
        let id = UUID()
        let type: String
        let count: Int
    }
    
    struct PriceDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let price: Double
    }
    
    private let chartColors: [Color] = [
        Color.blue.opacity(0.7),
        Color.purple.opacity(0.7),
        Color.indigo.opacity(0.7),
        Color.cyan.opacity(0.7)
    ]
    
    private func colorForIndex(_ index: Int) -> Color {
        chartColors[index % chartColors.count]
    }
    
    private func colorForType(_ type: String) -> Color {
        if let index = coffeeTypeData.firstIndex(where: { $0.type == type }) {
            return colorForIndex(index)
        }
        return .gray
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground).opacity(0.15) : Color(.systemBackground).opacity(0.5)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Spotřeba kávy")
                    .font(.headline)
                Spacer()
                
                Picker("Období", selection: $selectedPeriod) {
                    Text("Týden").tag(ChartPeriodType.week)
                    Text("Měsíc").tag(ChartPeriodType.month)
                    Text("Rok").tag(ChartPeriodType.year)
                }
                .pickerStyle(.segmented)
            }
            
            // Sloupcový graf spotřeby
            Chart {
                ForEach(chartData) { item in
                    BarMark(
                        x: .value("Datum", item.date, unit: selectedPeriod == .week ? .day : .month),
                        y: .value("Množství", item.amount)
                    )
                    .foregroundStyle(colorForType(item.type))
                    .cornerRadius(8)
                }
                
                if let selected = selectedDataPoint {
                    RuleMark(
                        x: .value("Selected", selected.date)
                    )
                    .foregroundStyle(Color.accentColor.opacity(0.3))
                    .annotation(position: .top) {
                        VStack {
                            Text(dateFormatter.string(from: selected.date))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(selected.amount))ml")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .bold()
                            Text(selected.type)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.9))
                        .cornerRadius(8)
                    }
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("\(Int(amount))ml")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: selectedPeriod == .week ? .day : .month)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(selectedPeriod == .week ? shortDateFormatter.string(from: date) : monthDateFormatter.string(from: date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let x = value.location.x
                                    if let date: Date = proxy.value(atX: x) {
                                        if let point = chartData.first(where: { Calendar.current.isDate($0.date, equalTo: date, toGranularity: selectedPeriod == .week ? .day : .month) }) {
                                            selectedDataPoint = point
                                        }
                                    }
                                }
                        )
                }
            }
            
            // Koláčový graf typů kávy
            HStack {
                Text("Poměr typů kávy")
                    .font(.headline)
                Spacer()
            }
            
            VStack {
                Chart(coffeeTypeData.indices, id: \.self) { index in
                    SectorMark(
                        angle: .value("Počet", coffeeTypeData[index].count),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(colorForIndex(index))
                    .annotation(position: .overlay) {
                        VStack {
                            Text(coffeeTypeData[index].type)
                                .font(.caption2)
                                .foregroundColor(.white)
                            Text("\(coffeeTypeData[index].count)×")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
                .frame(height: 200)
                
                // Legenda
                HStack(spacing: 16) {
                    ForEach(coffeeTypeData.indices, id: \.self) { index in
                        HStack {
                            Circle()
                                .fill(colorForIndex(index))
                                .frame(width: 10, height: 10)
                            Text(coffeeTypeData[index].type)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            // Čárový graf cen
            if !priceData.isEmpty {
                HStack {
                    Text("Vývoj cen")
                        .font(.headline)
                    Spacer()
                }
                
                Chart {
                    ForEach(priceData) { item in
                        LineMark(
                            x: .value("Datum", item.date, unit: selectedPeriod == .week ? .day : .month),
                            y: .value("Cena", item.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .symbol(Circle().strokeBorder(lineWidth: 2))
                    }
                    
                    ForEach(priceData) { item in
                        AreaMark(
                            x: .value("Datum", item.date),
                            y: .value("Cena", item.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
    }
    
    private var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let startDate: Date
        
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }
        
        return records
            .filter { ($0.date ?? Date()) >= startDate }
            .map { ChartDataPoint(date: $0.date ?? Date(), amount: $0.amount, type: $0.coffeeType.rawValue) }
            .sorted { $0.date < $1.date }
    }
    
    private var priceData: [PriceDataPoint] {
        let calendar = Calendar.current
        let startDate: Date
        
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }
        
        return records
            .filter { ($0.date ?? Date()) >= startDate }
            .compactMap { record in
                guard let price = record.price else { return nil }
                return PriceDataPoint(date: record.date ?? Date(), price: price)
            }
            .sorted { $0.date < $1.date }
    }
    
    private var coffeeTypeData: [CoffeeTypeDataPoint] {
        let types = records.map { $0.coffeeType.rawValue }
        let typeCounts = Dictionary(grouping: types, by: { $0 }).mapValues { $0.count }
        
        return typeCounts.map { type, count in
            CoffeeTypeDataPoint(type: type, count: count)
        }.sorted { $0.count > $1.count }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var monthDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
} 