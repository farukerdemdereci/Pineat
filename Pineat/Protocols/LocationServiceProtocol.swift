//
//  MapServiceProtocol.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 20.12.2025.
//

import Foundation
import UIKit

protocol LocationServiceProtocol {
    func saveLocations(title: String, description: String, latitude: Double, longitude: Double, image_url: String?) async throws
    
    func fetchLocations() async throws -> [Location]
    
    func uploadImage(image: UIImage) async throws -> String 
}
