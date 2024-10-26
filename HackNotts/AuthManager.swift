//
//  AuthManager.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI
import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userID: String = ""
    private var dataManager: DataManager?
    
    func setDataManager(_ dataManager: DataManager) {
            self.dataManager = dataManager
    }
    
    init() {
        // Set up Firebase auth listener
        Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async {
                self.isLoggedIn = user != nil
                self.userID = user?.uid ?? ""
                
                if user != nil {
                    self.dataManager?.fetchContracts()
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}
