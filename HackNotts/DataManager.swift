//
//  DataManager.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

class DataManager: ObservableObject {
    @Published var contracts: [Contract] = []
    @Published var users: [User] = []
    
    
    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("Users")
          .order(by: "name")
          .limit(to: 50)  // Limit initial fetch to 50 users
          .getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                self.users = snapshot.documents.map { document in
                    let data = document.data()
                    return User(
                        id: document.documentID,
                        email: data["email"] as? String ?? "",
                        name: data["name"] as? String ?? ""
                    )
                }
            }
        }
    }
    
    func searchUsers(matching query: String) {
            guard !query.isEmpty else {
                fetchUsers()
                return
            }
            
            let db = Firestore.firestore()
            db.collection("Users")
              .whereField("name", isGreaterThanOrEqualTo: query)
              .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
              .limit(to: 10)
              .getDocuments { snapshot, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    self.users = snapshot.documents.map { document in
                        let data = document.data()
                        return User(
                            id: document.documentID,
                            email: data["email"] as? String ?? "",
                            name: data["name"] as? String ?? ""
                        )
                    }
                }
            }
        }
    
    func createUserProfile(userId: String, email: String, name: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userId)
        
        let userData: [String: Any] = [
            "email": email,
            "name": name
        ]
        
        userRef.setData(userData) { error in
            if let error = error {
                print("Error creating user profile: \(error)")
            } else {
                self.fetchUsers()
            }
        }
    }
    
    func addContract(name: String, description: String, amount: Double, partnerId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("Contracts").document()
        
        let data: [String: Any] = [
            "name": name,
            "description": description,
            "amount": amount,
            "partnerId": partnerId,  
            "isCompleted": false,
            "userId": userId
        ]
        
        ref.setData(data) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.fetchContracts()
            }
        }
    }
    
    func fetchContracts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        contracts.removeAll()
        let db = Firestore.firestore()
        
        db.collection("Contracts")
            .whereFilter(Filter.orFilter([
                Filter.whereField("userId", isEqualTo: userId),
                Filter.whereField("partnerId", isEqualTo: userId)
            ]))
            .getDocuments { snapshot, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    self.contracts = snapshot.documents.map { document in
                        let data = document.data()
                        return Contract(
                            id: document.documentID,  // Use document ID for unique identifier
                            name: data["name"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            amount: data["amount"] as? Double ?? 0.0,
                            partnerId: data["partnerId"] as? String ?? "",
                            isCompleted: data["isCompleted"] as? Bool ?? false,
                            userId: data["userId"] as? String ?? ""
                        )
                    }
                }
            }
    }
}
