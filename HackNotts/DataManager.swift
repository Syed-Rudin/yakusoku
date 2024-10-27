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
    @Published var friends: [Friend] = []
    
    private var friendIds: Set<String> {
            Set(friends.map { $0.friendId })
    }

    func fetchFriends() {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            db.collection("Friends")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    if let snapshot = snapshot {
                        self.friends = snapshot.documents.map { document in
                            let data = document.data()
                            return Friend(
                                id: document.documentID,
                                userId: data["userId"] as? String ?? "",
                                friendId: data["friendId"] as? String ?? "",
                                dateAdded: (data["dateAdded"] as? Timestamp)?.dateValue() ?? Date()
                            )
                        }
                    }
                }
        }
        
        func addFriend(friendId: String) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            let ref = db.collection("Friends").document()
            
            let data: [String: Any] = [
                "userId": userId,
                "friendId": friendId,
                "dateAdded": Timestamp(date: Date())
            ]
            
            ref.setData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.fetchFriends()
                }
            }
        }
        
        func removeFriend(friendId: String) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            db.collection("Friends")
                .whereField("userId", isEqualTo: userId)
                .whereField("friendId", isEqualTo: friendId)
                .getDocuments { snapshot, error in
                    if let document = snapshot?.documents.first {
                        document.reference.delete { error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                self.fetchFriends()
                            }
                        }
                    }
                }
        }
        
        func isFriend(_ userId: String) -> Bool {
            friendIds.contains(userId)
        }
    
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
    
    func addContract(name: String, description: String, amount: Double, partnerId: String, dueDate: Date) {
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
               "userId": userId,
               "status": Contract.ContractStatus.pending.rawValue,
               "dueDate": Timestamp(date: dueDate),
               "completedDate": NSNull()
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
                           
                           // Convert Firestore Timestamp to Date
                           let dueDateTimestamp = data["dueDate"] as? Timestamp
                           let completedDateTimestamp = data["completedDate"] as? Timestamp
                           
                           return Contract(
                               id: document.documentID,
                               name: data["name"] as? String ?? "",
                               description: data["description"] as? String ?? "",
                               amount: data["amount"] as? Double ?? 0.0,
                               partnerId: data["partnerId"] as? String ?? "",
                               userId: data["userId"] as? String ?? "",
                               dueDate: dueDateTimestamp?.dateValue() ?? Date(),
                               status: Contract.ContractStatus(rawValue: data["status"] as? String ?? "pending") ?? .pending,
                               completedDate: completedDateTimestamp?.dateValue()
                           )
                       }
                   }
               }
       }
    
    
}

extension DataManager {
    func updateContractStatus(contractId: String, status: Contract.ContractStatus) {
        let db = Firestore.firestore()
        let ref = db.collection("Contracts").document(contractId)
        
        let data: [String: Any] = [
            "status": status.rawValue,
            "completedDate": Timestamp(date: Date())
        ]
        
        ref.updateData(data) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.fetchContracts()
            }
        }
    }
}
