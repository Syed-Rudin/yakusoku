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
        dataManager.contracts.filter { $0.userId == authManager.userID && $0.status == .pending }
    }
    
    var friendContracts: [Contract] {
        dataManager.contracts.filter { $0.partnerId == authManager.userID && $0.status == .pending }
    }
    
    var historyContracts: [Contract] {
        dataManager.contracts
            .filter { $0.userId == authManager.userID && $0.isComplete }
            .sorted { ($0.completedDate ?? Date()) > ($1.completedDate ?? Date()) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // My Promises Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("My Promises")
                                .font(.title3)
                                .bold()
                            Spacer()
                            Button(action: { showPopup.toggle() }) {
                                Image(systemName: "plus")
                            }
                        }
                        .padding(.horizontal)
                
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if myContracts.isEmpty {
                                    EmptyPromiseCard(message: "No active promises")
                                } else {
                                    ForEach(myContracts) { contract in
                                        PromiseCard(contract: contract)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Friends' Promises Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Friends' Promises")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if friendContracts.isEmpty {
                                    EmptyPromiseCard(message: "No friend promises")
                                } else {
                                    ForEach(friendContracts) { contract in
                                        PromiseCard(contract: contract)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // History Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("History")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(historyContracts) { contract in
                                HistoryRow(contract: contract)
                                Divider()
                            }
                        }
                        .background(Color(.systemBackground))
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("今日の約束")
            .sheet(isPresented: $showPopup) {
                NewPromiseView()
            }
            .onAppear {
                dataManager.fetchContracts()
            }
        }
    }
}

// Card view for promises
struct PromiseCard: View {
    let contract: Contract
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    
    private var isPartner: Bool {
        contract.partnerId == authManager.userID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(contract.name)
                .font(.headline)
                .lineLimit(2)
            
            Text("$\(contract.amount, specifier: "%.2f")")
                .font(.title2)
                .bold()
                .foregroundColor(.blue)
            
            HStack {
                Image(systemName: "clock")
                Text(contract.dueDate, style: .date)
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            if contract.isOverdue {
                Text("Overdue")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
            
            // Partner Actions
            if isPartner && contract.status == .pending {
                Divider()
                
                HStack(spacing: 8) {
                    // Success Button
                    if contract.canBeMarkedAsSuccess {
                        Button(action: {
                            dataManager.updateContractStatus(contractId: contract.id, status: .success)
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Success")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(4)
                        }
                    }
                    
                    // Fail Button (only shows if overdue)
                    if contract.canBeMarkedAsFailed {
                        Button(action: {
                            dataManager.updateContractStatus(contractId: contract.id, status: .failed)
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Fail")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}


// Empty state card
struct EmptyPromiseCard: View {
    let message: String
    
    var body: some View {
        VStack {
            Text(message)
                .foregroundColor(.gray)
        }
        .frame(width: 200, height: 150)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// History row view
struct HistoryRow: View {
    let contract: Contract
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contract.name)
                    .font(.headline)
                if let completedDate = contract.completedDate {
                    Text(completedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Status indicator
            Text(contract.status == .success ? "Success" : "Failed")
                .font(.subheadline)
                .foregroundColor(contract.status == .success ? .green : .red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    (contract.status == .success ? Color.green : Color.red)
                        .opacity(0.1)
                )
                .cornerRadius(8)
        }
        .padding()
    }
}

// Separate view for each contract row
struct ContractRow: View {
    let contract: Contract
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingActionSheet = false
    
    private var isPartner: Bool {
        contract.partnerId == authManager.userID
    }
    
    private var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: contract.dueDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(contract.name)
                .font(.headline)
            
            Text("$\(contract.amount, specifier: "%.2f")")
                .foregroundColor(.blue)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(contract.isOverdue ? .red : .gray)
                Text(formattedDueDate)
                    .font(.caption)
                    .foregroundColor(contract.isOverdue ? .red : .gray)
            }
            
            // Status display
            switch contract.status {
            case .success:
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Success")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            case .failed:
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Failed")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            case .pending:
                if contract.isOverdue {
                    Text("Overdue!")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            // Partner actions
            if isPartner && contract.status == .pending {
                HStack {
                    if contract.canBeMarkedAsSuccess {
                        Button(action: {
                            dataManager.updateContractStatus(contractId: contract.id, status: .success)
                        }) {
                            Text("Mark as Success")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                    
                    if contract.canBeMarkedAsFailed {
                        Button(action: {
                            dataManager.updateContractStatus(contractId: contract.id, status: .failed)
                        }) {
                            Text("Mark as Failed")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}


struct ContractListView_Previews: PreviewProvider {
    static var previews: some View {
        ContractListView()
            .environmentObject(DataManager())
            .environmentObject(AuthManager())
    }
}
