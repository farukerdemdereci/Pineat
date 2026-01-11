//
//  AuthViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signUp(email: email, password: password)
            isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signOut()
            isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
