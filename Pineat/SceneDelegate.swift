//
//  SceneDelegate.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private let manager: SupabaseManager = {
        let client = SupabaseClient(
            supabaseURL: URL(string: "URL")!,
            supabaseKey: "KEY"
        )
        return SupabaseManager(client: client)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        checkAuthentication()
        
        window?.makeKeyAndVisible()
    }
}

// MARK: - Auth Logic
extension SceneDelegate {
    private func checkAuthentication() {
        if manager.client.auth.currentUser != nil {
            window?.rootViewController = createTabBar()
            
        } else {
            window?.rootViewController = createLoginVC()
        }
    }
    
    func resetToLogin() {
        DispatchQueue.main.async {
            self.window?.rootViewController = self.createLoginVC()
            
            if let window = self.window {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
    
    func resetToMainApp() {
        DispatchQueue.main.async {
            self.window?.rootViewController = self.createTabBar()
            
            if let window = self.window {
                UIView.transition(with: window,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: nil)
            }
        }
    }
}

// MARK: - Dependency Injection
extension SceneDelegate {
    private func createTabBar() -> UITabBarController {
        let tabBar = UITabBarController()
        
        // 1. Liste
        let listVM = ListViewModel(listService: manager)
        let listVC = ListViewController(vm: listVM)
        listVC.tabBarItem = UITabBarItem(title: "Mekanlar", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        // 2. Harita
        let locationVM = LocationViewModel(locationService: manager)
        let locationVC = LocationViewController(vm: locationVM)
        locationVC.tabBarItem = UITabBarItem(title: "Harita", image: UIImage(systemName: "map"), tag: 1)
        
        // 3. Profil (YENİ)
        let profileVM = AuthViewModel(authService: manager) // Profil VM'ini de manager ile besle
        let profileVC = ProfileViewController(vm: profileVM)
        profileVC.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person.circle"), tag: 2)
        
        tabBar.viewControllers = [
            UINavigationController(rootViewController: listVC),
            UINavigationController(rootViewController: locationVC),
            UINavigationController(rootViewController: profileVC)
        ]
        
        return tabBar
    }
    
    private func createLoginVC() -> UIViewController {
        let board = UIStoryboard(name: "Main", bundle: nil)
        
        // 1. Ekranı Storyboard'dan alıyoruz
        guard let loginVC = board.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            fatalError("")
        }
        
        loginVC.vm = AuthViewModel(authService: manager)
        
        return loginVC
    }
}
