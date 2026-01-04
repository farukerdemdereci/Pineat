//
//  SceneDelegate.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let client = SupabaseManager.shared.client
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard (scene is UIWindowScene) else { return }

        let currentUser = client.auth.currentUser
        
        if currentUser != nil {
            let board = UIStoryboard(name: "Main", bundle: nil)
            if let tabBar = board.instantiateViewController(withIdentifier: "tabBar") as? UITabBarController {
                window?.rootViewController = tabBar
            }
        }
    }

    func resetToLogin() {
        DispatchQueue.main.async {
            let board = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = board.instantiateViewController(withIdentifier: "LoginViewController")
            
            self.window?.rootViewController = loginVC
            
            if let window = self.window {
                UIView.transition(with: window,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: nil,
                                completion: nil)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}

