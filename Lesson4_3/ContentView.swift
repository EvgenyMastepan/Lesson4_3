//
//  NetworkManager.swift
//  Lesson4_3
//
//  Created by Evgeny Mastepan on 25.02.2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var selectedDate = Date() // Выбранная дата
    @State private var showYearPicker = false // Показывать ли календарь
    @State private var showSuccessfulOnly = false // Фильтр успешных запусков
    
    // Ограничиваем выбор года (2006 — текущий год)
    private let minYear = 2006
    private let maxYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            // Поле для отображения выбранного года и кнопка сброса
            HStack {
                Text("Выбранный год: \(formattedYear)")
                    .font(.headline)
                
                Button(action: {
                    showYearPicker.toggle() // Показать/скрыть календарь
                }) {
                    Image(systemName: "calendar")
                        .font(.title)
                }
                
                // Кнопка "Сбросить фильтр"
                Button(action: {
                    selectedDate = Date() // Сбросить дату на текущий год
                    fetchLaunchesForSelectedYear() // Загрузить данные для текущего года
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
            .padding()
            
            // Кнопка-переключатель для фильтрации успешных запусков
            Toggle(isOn: $showSuccessfulOnly) {
                Text("Показывать только успешные запуски")
                    .font(.headline)
            }
            .padding()
            .onChange(of: showSuccessfulOnly) { _ in
                fetchLaunchesForSelectedYear() // Перезагрузить данные при изменении фильтра
            }
            
            // Календарь для выбора года с анимацией
            if showYearPicker {
                DatePicker(
                    "Select Year",
                    selection: $selectedDate,
                    in: dateRange, // Ограничиваем диапазон дат
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .onChange(of: selectedDate) { newDate in
                    showYearPicker = false // Скрыть календарь после выбора
                    fetchLaunchesForSelectedYear() // Загрузить данные для выбранного года
                }
                .padding()
                .transition(.opacity.combined(with: .scale)) // Анимация появления
            }
            
            // Индикатор загрузки
            if networkManager.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                // Список запусков с разделителями
                List {
                    ForEach(filteredLaunches.sorted(by: { $0.date_utc > $1.date_utc })) { launch in
                        VStack(alignment: .leading) {
                            Text(launch.name)
                                .font(.headline)
                            Text(launch.date_utc)
                                .font(.subheadline)
                            Text(launch.details ?? "No details available")
                                .font(.caption)
                            if let success = launch.success {
                                Text(success ? "Success" : "Failure")
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
            fetchLaunchesForSelectedYear() // Загрузить данные для текущего года при старте
        }
        .animation(.easeInOut, value: showYearPicker) // Анимация для календаря
    }
    
    // Форматируем выбранную дату в год


private var formattedYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedDate)
    }
    
    // Ограничиваем диапазон дат (2006 — текущий год)
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
    
    // Фильтруем запуски по успешности
    private var filteredLaunches: [Launch] {
        if showSuccessfulOnly {
            return networkManager.launches.filter { $0.success == true }
        } else {
            return networkManager.launches
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
