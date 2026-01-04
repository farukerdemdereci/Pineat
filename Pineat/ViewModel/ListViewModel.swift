//
//  ListViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 26.12.2025.
//

import Foundation

@MainActor
class ListViewModel: ObservableObject {
    @Published var locationArray: [Location] = []
    @Published var filteredArray: [Location] = [] 
    
    private let listService: ListServiceProtocol

    init(listService: ListServiceProtocol = SupabaseManager.shared) {
        self.listService = listService
    }

    func fetchLocations() async {
        do {
            let fetched = try await listService.fetchLocations()
            
            self.locationArray = fetched.reversed()
            self.filteredArray = self.locationArray
        } catch { print(error) }
    }

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredArray = locationArray
        } else {
            filteredArray = locationArray.filter { location in
                return location.title.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func deleteLocation(id: UUID) async {
        do {
            try await listService.deleteLocations(id: id)

            self.locationArray.removeAll { $0.id == id }
            self.filteredArray.removeAll { $0.id == id }
            
        } catch { }
    }
}
