//
//  ListServiceProtocol.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 26.12.2025.
//

import Foundation

protocol ListServiceProtocol {
    func fetchLocations() async throws -> [Location]
    
    func deleteLocations(id: UUID) async throws
}
