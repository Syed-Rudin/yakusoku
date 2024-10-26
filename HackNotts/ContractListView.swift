//
//  ContractListView.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct ContractListView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showPopup = false
    
    var myContracts: [Contract] {
        dataManager.contracts.filter { $0.userId == Auth.auth().currentUser?.uid }
    }
    
    var friendContracts: [Contract] {
        dataManager.contracts.filter { $0.partnerId == Auth.auth().currentUser?.uid }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // My Contracts Section
                    VStack(alignment: .leading) {
                        Text("My Contracts")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        if myContracts.isEmpty {
                            Text("No contracts yet")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(myContracts) { contract in
                                ContractRow(contract: contract)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Friend's Contracts Section
                    VStack(alignment: .leading) {
                        Text("Friends' Contracts")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        if friendContracts.isEmpty {
                            Text("No friend contracts yet")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(friendContracts) { contract in
                                ContractRow(contract: contract)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Contracts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showPopup.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showPopup) {
                NewContractView()
            }
            .onAppear {
                dataManager.fetchContracts()
            }
        }
    }
}

// Separate view for each contract row
struct ContractRow: View {
    let contract: Contract
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(contract.name)
                .font(.headline)
            Text("$\(contract.amount, specifier: "%.2f")")
                .foregroundColor(.blue)
            if contract.isCompleted {
                Text("Completed ✓")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
}

struct ContractListView_Previews: PreviewProvider {
    static var previews: some View {
        ContractListView()
            .environmentObject(DataManager())
            .environmentObject(AuthManager())
    }
}
