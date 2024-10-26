//
//  DataManager.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI
import Firebase

class DataManager: ObservableObject {
    @Published var contracts: [Contract] = []
    
    init() {
        fetchContracts()
    }
    
    func fetchContracts() {
        contracts.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Contracts")
        ref.getDocuments { snapshot, error in
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
                    
                    let contract = Contract(id: id,
                                         name: name,
                                         description: description,
                                         amount: amount,
                                         partnerId: partnerId,
                                         isCompleted: isCompleted)
                    self.contracts.append(contract)
                }
            }
        }
    }
    
    func addContract(name: String, description: String, amount: Double, partnerId: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Contracts").document()
        
        let data: [String: Any] = [
            "name": name,
            "description": description,
            "amount": amount,
            "partnerId": partnerId,
            "isCompleted": false
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
