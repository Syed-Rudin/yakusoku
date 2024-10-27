//
//  HackNottsApp.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI
import Firebase

@main
struct HackNottsApp: App {
    @StateObject var authManager = AuthManager()
    @StateObject var dataManager = DataManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                MainTabView()
                    .environmentObject(authManager)
                    .environmentObject(dataManager)
                    .onAppear {
                        authManager.setDataManager(dataManager)
                    }
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
