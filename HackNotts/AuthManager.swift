//
//  AuthManager.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userID: String = ""
    @Published var currentUser: User?
    private var dataManager: DataManager?
    
    func setDataManager(_ dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func register(email: String, password: String, name: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            if let userId = result?.user.uid {
                let db = Firestore.firestore()
                let userRef = db.collection("Users").document(userId)
                
                let userData: [String: Any] = [
                    "email": email,
                    "name": name,
                    "createdAt": Timestamp()
                ]
                
                userRef.setData(userData) { error in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        self?.fetchUserProfile(userId: userId)
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let userId = result?.user.uid {
                self?.fetchUserProfile(userId: userId)
            }
        }
    }
    
    private func fetchUserProfile(userId: String) {
        let db = Firestore.firestore()
        db.collection("Users").document(userId).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                print("Error fetching user profile: \(error?.localizedDescription ?? "")")
                return
            }
            
            DispatchQueue.main.async {
                self?.currentUser = User(
                    id: userId,
                    email: data["email"] as? String ?? "",
                    name: data["name"] as? String ?? ""
                )
                self?.isLoggedIn = true
                self?.userID = userId
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.userID = ""
            self.currentUser = nil
        } catch {
            print(error.localizedDescription)
        }
    }
}

