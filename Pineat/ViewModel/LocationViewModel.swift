//
//  LocationViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation
import Supabase
import UIKit

@MainActor
class LocationViewModel: ObservableObject {
    
    @Published var locationArray: [Location] = []
    @Published var isLoading: Bool = false
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    let locationService: LocationServiceProtocol
    
    init(locationService: LocationServiceProtocol = SupabaseManager.shared) {
        self.locationService = locationService
    }
    
    func fetchAllLocations() async {
        do {
            
            let fetchedLocations = try await locationService.fetchLocations()
            self.locationArray = fetchedLocations
        } catch { }
    }
    
    func saveLocations(title: String, description: String, latitude: Double, longitude: Double, image: UIImage?) {
        isLoading = true
        Task {
            do {
                var finalImageUrl: String = ""
                
                if let image = image, image.symbolConfiguration == nil {
                    finalImageUrl = try await SupabaseManager.shared.uploadImage(image: image)
                }
                
                try await locationService.saveLocations(
                    title: title,
                    description: description,
                    latitude: latitude,
                    longitude: longitude,
                    image_url: finalImageUrl
                )
                
                await fetchAllLocations()
                
                isLoading = false
            } catch { isLoading = false }
        }
    }
}
