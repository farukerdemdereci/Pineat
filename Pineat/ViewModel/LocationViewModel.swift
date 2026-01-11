//
//  LocationViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation
import UIKit

@MainActor
class LocationViewModel: ObservableObject {
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var locationArray: [Location] = []
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    let locationService: LocationServiceProtocol
    
    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }
    
    func fetchLocations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedLocations = try await locationService.fetchLocations()
            self.locationArray = fetchedLocations
            isLoading = false
            
        } catch {
            self.errorMessage = "Konumlar yüklenemedi: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func saveLocations(title: String, description: String, latitude: Double, longitude: Double, image: UIImage?) async {
        isLoading = true
        errorMessage = nil
        do {
            var finalImageUrl: String = ""
            
            if let image = image {
                finalImageUrl = try await locationService.uploadImage(image: image)
            }
            
            try await locationService.saveLocations(
                title: title,
                description: description,
                latitude: latitude,
                longitude: longitude,
                image_url: finalImageUrl
            )
            
            await fetchLocations()
            isLoading = false
        } catch {
            self.errorMessage = "Kaydedilemedi: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
