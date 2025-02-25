//
//  NetworkManager.swift
//  Lesson4_3
//
//  Created by Evgeny Mastepan on 25.02.2025.
//

import Foundation
import Combine
import CoreText

class NetworkManager: ObservableObject{
    @Published var launches: [Launch] = []
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    func fetchLaunches(year: String?){
        isLoading = true
        
        var urlString = "https://api.spacexdata.com/v4/launches"
        if let year = year{
            urlString += "?year=\(year)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map {$0.data}
            .decode(type: [Launch].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                  self.isLoading = false
                  switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error fetching launches: \(error)")
                  }
            }, receiveValue: { [weak self] launches in
                self?.launches = launches
            })
            .store(in: &cancellables)
    }
}


