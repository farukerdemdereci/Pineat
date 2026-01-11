//
//  ListViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 26.12.2025.
//

import Foundation

@MainActor
class ListViewModel: ObservableObject {
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var locationArray: [Location] = []
    @Published var filteredArray: [Location] = []
    
    private let listService: ListServiceProtocol

    init(listService: ListServiceProtocol) {
        self.listService = listService
    }

    func fetchLocations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await listService.fetchLocations()
            
            self.locationArray = fetched.reversed()
            self.filteredArray = self.locationArray
            
            isLoading = false
            
        } catch {
            self.errorMessage = "Liste yüklenirken bir hata oluştu: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func deleteLocation(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await listService.deleteLocations(id: id)

            self.locationArray.removeAll { $0.id == id }
            self.filteredArray.removeAll { $0.id == id }
            
            isLoading = false
            
        } catch {
            self.errorMessage = "Silme işlemi başarısız oldu: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredArray = locationArray
            
        } else {
            filteredArray = locationArray.filter { location in
                location.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
