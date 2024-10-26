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
    
    init() {
        
    }
    
    func fetchContracts() {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        contracts.removeAll()
        let db = Firestore.firestore()
        
        db.collection("Contracts")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        let data = document.data()
                        
                        let id = document.documentID
                        let name = data["name"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let amount = data["amount"] as? Double ?? 0.0
                        let partnerId = data["partnerId"] as? String ?? ""
                        let isCompleted = data["isCompleted"] as? Bool ?? false
                        let userId = data["userId"] as? String ?? ""
                        
                        let contract = Contract(id: id,
                                             name: name,
                                             description: description,
                                             amount: amount,
                                             partnerId: partnerId,
                                             isCompleted: isCompleted,
                                             userId: userId)
                        self.contracts.append(contract)
                    }
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
    
    func markContractComplete(contractId: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Contracts").document(contractId)
        
        ref.updateData([
            "isCompleted": true
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.fetchContracts()
            }
        }
    }
}
