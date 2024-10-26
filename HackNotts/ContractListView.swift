//
//  ContractListView.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI

struct ContractListView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showPopup = false
    
    var body: some View {
        NavigationView {
            List(dataManager.contracts, id: \.id) { contract in
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
        }
    }
}


struct ContractListView_Previews: PreviewProvider {
    static var previews: some View {
        ContractListView()
            .environmentObject(DataManager())
            .environmentObject(AuthManager())
    }
}
