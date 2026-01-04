//
//  AuthViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation
import Supabase

class AuthViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = SupabaseManager.shared) {
        self.authService = authService
    }
    
    func signIn(email: String, password: String) async {
        do {
            try await authService.signIn(email: email, password: password)

        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    func signUp(email: String, password: String) async {
        do {
            try await authService.signUp(email: email, password: password)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
