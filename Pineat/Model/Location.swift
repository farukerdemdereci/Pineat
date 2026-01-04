//
//  Location.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation

struct Location: Codable {
    var id: UUID
    let user_id: UUID
    let title: String
    let description: String
    let latitude: Double
    let longitude: Double
    let image_url: String?
}
