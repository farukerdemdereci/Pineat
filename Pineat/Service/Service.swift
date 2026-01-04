//
//  Service.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation
import Supabase
import UIKit

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "SUPABASE_URL_HERE")!,
            supabaseKey: "SUPABASE_KEY_HERE")
    }
    
    func uploadImage(image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: -1)
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        
        try await client.storage
            .from("images")
            .upload(fileName, data: data)
        
        let url = try client.storage
            .from("images")
            .getPublicURL(path: fileName)
        
        return url.absoluteString
    }
}

extension SupabaseManager: AuthServiceProtocol {
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
}

extension SupabaseManager: LocationServiceProtocol, ListServiceProtocol {
    func fetchLocations() async throws -> [Location] {
        guard let session = try? await client.auth.session else {
            throw Auth.AuthError.sessionMissing
        }
        
        let userId = session.user.id
 
        let locations: [Location] = try await client
            .from("locations")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return locations
    }

    func saveLocations(title: String, description: String, latitude: Double, longitude: Double, image_url: String?) async throws {
        guard let session = try? await client.auth.session else {
            throw Auth.AuthError.sessionMissing
        }
        
        let userId = session.user.id
        
        let location = Location(
            id: UUID(),
            user_id: userId,
            title: title,
            description: description,
            latitude: latitude,
            longitude: longitude,
            image_url: image_url
        )
        
        try await client
            .from("locations")
            .insert(location)
            .execute()
    }

    func deleteLocations(id: UUID) async throws {
        try await client
            .from("locations")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
