//
//  NetworkManager.swift
//  Lesson4_3
//
//  Created by Evgeny Mastepan on 25.02.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var selectedDate = Date()
    @State private var showYearPicker = false // Флаг показа выбора календаря.
    @State private var showSuccessfulOnly = false // Флаг показа только успешных запусков.
    @State private var isFilteredByYear = false // Флаг для фильтрации по году.
    
    // До 2006 запусков у СпейсИкс не было. Поэтому ограничивает от 2006 по сегодняшнюю дату.
    // Алярма! Данных с 2023 по 2025 год почему-то нет в этом API. Это проблема на их стороне!
    // Выбираем с 2006 по 2022.
    private let minYear = 2006
    private let maxYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            Image("1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .clipped()
            HStack {
                Text(isFilteredByYear ? "Запуски за год: \(formattedYear)" : "Запуски всех лет")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showYearPicker.toggle()
                }) {
                    Image(systemName: "calendar")
                        .font(.title)
                }
                
                Button(action: {
                    isFilteredByYear = false
                    networkManager.fetchLaunches(year: nil)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
            
            Toggle(isOn: $showSuccessfulOnly) {
                Text("Только успешные запуски")
                    .font(.headline)
            }
            
            if showYearPicker {
                DatePicker(
                    "Select Year",
                    selection: $selectedDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .onChange(of: selectedDate) { newDate in
                    showYearPicker = false
                    isFilteredByYear = true
                    fetchLaunchesForSelectedYear()
                }
                .padding()
                .transition(.opacity.combined(with: .scale))
            }
            
            if networkManager.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
//                    .progressViewStyle(LinearProgressViewStyle())
//                    .progressViewStyle(DefaultProgressViewStyle())
                    .padding()
            } else {
                List {
                    ForEach(filteredLaunches.sorted(by: { $0.date_utc > $1.date_utc })) { launch in
                        VStack(alignment: .leading) {
                            Text(launch.name)
                                .font(.headline)
                            Text(formatDate(launch.date_utc))
                                .font(.subheadline)
                            Text(launch.details ?? "Нет подробностей...")
                                .font(.caption)
                            if let success = launch.success {
                                Text(success ? "Успешный" : "Неудачный")
                                    .foregroundColor(success ? .green : .red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            networkManager.fetchLaunches(year: nil)
        }
        .animation(.easeInOut, value: showYearPicker)
    }

    // Форматируем дату в год только
        private var formattedYear: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: selectedDate)
        }
        
        // Ограничиваем диапазон дат
        private var dateRange: ClosedRange<Date> {
            let calendar = Calendar.current
            let minDate = calendar.date(from: DateComponents(year: minYear, month: 1, day: 1))!
            let maxDate = calendar.date(from: DateComponents(year: maxYear, month: 12, day: 31))!
            return minDate...maxDate
        }
        
        // Загрузить данные для выбранного года
        private func fetchLaunchesForSelectedYear() {
            networkManager.fetchLaunches(year: formattedYear)
        }
        
        // Фильтруем запуски по году и успешности
        private var filteredLaunches: [Launch] {
            var launches = networkManager.launches
            
            // Фильтрация по году (у API глюк - не фильтрует по году. Поэтому делаем сами.)
            if isFilteredByYear {
                let year = formattedYear
                launches = launches.filter { launch in
                    let launchYear = String(launch.date_utc.prefix(4))
                    return launchYear == year
                }
            }
            
            // Фильтр по успешности
            if showSuccessfulOnly {
                launches = launches.filter { $0.success == true }
            }
            
            return launches
        }
        
        // Форматируем дату
        private func formatDate(_ dateString: String) -> String {
            let inputFormatter = ISO8601DateFormatter()
            guard let date = inputFormatter.date(from: dateString) else {
                return dateString
            }
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
            return outputFormatter.string(from: date)
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
