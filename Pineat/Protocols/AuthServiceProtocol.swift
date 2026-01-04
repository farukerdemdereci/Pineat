//
//  AuthServiceProtocol.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 19.12.2025.
//

import Foundation

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    
    func signUp(email: String, password: String) async throws
    
    func signOut() async throws
}
