//
//  NewContractView.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI

struct NewContractView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var amount = ""
    @State private var showingUserPicker = false
    @State private var selectedPartnerId = ""
    @State private var selectedPartnerName = "Select Partner"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contract Details")) {
                    TextField("Contract Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Accountability Partner")) {
                    Button(action: {
                        showingUserPicker = true
                    }) {
                        HStack {
                            Text(selectedPartnerName)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("New Contract")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContract()
                    }
                    .disabled(name.isEmpty || description.isEmpty ||
                            amount.isEmpty || selectedPartnerId.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingUserPicker) {
                UserPickerView(selectedUserId: $selectedPartnerId,
                             selectedUserName: $selectedPartnerName)
            }
        }
    }
    
    private func saveContract() {
        if let amountDouble = Double(amount) {
            dataManager.addContract(
                name: name,
                description: description,
                amount: amountDouble,
                partnerId: selectedPartnerId
            )
            dismiss()
        }
    }
}

struct UserPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthManager
    @Binding var selectedUserId: String
    @Binding var selectedUserName: String
    @State private var searchText = ""
    
    var filteredUsers: [User] {
        guard !searchText.isEmpty else {
            // When search is empty, show all users except current user
            return dataManager.users.filter { $0.id != authManager.currentUser?.id }
        }
        
        // Filter users based on search text and exclude current user
        return dataManager.users.filter { user in
            user.id != authManager.currentUser?.id &&
            (user.name.lowercased().contains(searchText.lowercased()) ||
             user.email.lowercased().contains(searchText.lowercased()))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search users...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                if filteredUsers.isEmpty {
                    VStack(spacing: 10) {
                        if searchText.isEmpty {
                            Text("No other users found")
                                .foregroundColor(.gray)
                        } else {
                            Text("No users match '\(searchText)'")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(filteredUsers) { user in
                        Button(action: {
                            selectedUserId = user.id
                            selectedUserName = user.name
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if selectedUserId == user.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Partner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            dataManager.fetchUsers()
        }
    }
}

// Preview provider
struct UserPickerView_Previews: PreviewProvider {
    @State static var selectedId = ""
    @State static var selectedName = ""
    
    static var previews: some View {
        UserPickerView(selectedUserId: $selectedId, selectedUserName: $selectedName)
            .environmentObject(DataManager())
            .environmentObject(AuthManager())
    }
}

struct NewContractView_Previews: PreviewProvider {
    static var previews: some View {
        NewContractView()
            .environmentObject(DataManager())
    }
}
