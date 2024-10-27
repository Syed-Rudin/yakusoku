//
//  NewContractView.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI

struct NewPromiseView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var amount = 5.0
    @State private var showingUserPicker = false
    @State private var selectedPartnerId = ""
    @State private var selectedPartnerName = "Select Partner"
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.customDarkPurple
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    // Title section
                    Text("Promise Details")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.top, 20)
                    
                    // Form fields
                    VStack(alignment: .leading, spacing: 20) {
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            TextField("", text: $title)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        // Description field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (100 word limit)")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            TextEditor(text: $description)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .tint(.white)  // This changes the cursor color
                                .scrollContentBackground(.hidden)  // This removes the white background
                                .onChange(of: description) { newValue in
                                    if newValue.count > 100 {
                                        description = String(newValue.prefix(100))
                                    }
                                }
                        }
                        
                        // Date and Time pickers
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .colorInvert()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .colorInvert()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Penalty slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Penalty: £\(Int(amount))")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            Slider(value: $amount, in: 0...100, step: 1)
                                .accentColor(.customOrange)
                                .padding(.vertical, 8)
                        }
                    }
                    
                    // Accountability Partner section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Accountability Partner")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            showingUserPicker = true
                        }) {
                            HStack {
                                Text(selectedPartnerName)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.customOrange)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.customOrange)
                }
                ToolbarItem(placement: .principal) {
                    Text("New Promise")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePromise()
                    }
                    .disabled(title.isEmpty || description.isEmpty || selectedPartnerId.isEmpty)
                    .foregroundColor(.customOrange)
                }
            }
        }
        .sheet(isPresented: $showingUserPicker) {
            UserPickerView(selectedUserId: $selectedPartnerId,
                         selectedUserName: $selectedPartnerName)
        }
    }
    
    private func savePromise() {
        let calendar = Calendar.current
        let finalDate = calendar.date(bySettingHour: calendar.component(.hour, from: selectedTime),
                                    minute: calendar.component(.minute, from: selectedTime),
                                    second: 0,
                                    of: selectedDate) ?? selectedDate
        
        dataManager.addContract(
            name: title,
            description: description,
            amount: amount,
            partnerId: selectedPartnerId,
            dueDate: finalDate
        )
        dismiss()
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
            return dataManager.users.filter { $0.id != authManager.currentUser?.id }
        }
        
        return dataManager.users.filter { user in
            user.id != authManager.currentUser?.id &&
            (user.name.lowercased().contains(searchText.lowercased()) ||
             user.email.lowercased().contains(searchText.lowercased()))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.customDarkPurple
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.customOrange)
                        
                        TextField("Search users...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    if filteredUsers.isEmpty {
                        VStack(spacing: 10) {
                            if searchText.isEmpty {
                                Text("No other users found")
                                    .foregroundColor(.white)
                            } else {
                                Text("No users match '\(searchText)'")
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredUsers) { user in
                                    Button(action: {
                                        selectedUserId = user.id
                                        selectedUserName = user.name
                                        dismiss()
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(user.name)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 16))
                                                Text(user.email)
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 14))
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedUserId == user.id {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.customOrange)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.customOrange)
                }
                ToolbarItem(placement: .principal) {
                    Text("Select Partner")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            dataManager.fetchUsers()
        }
    }
}

struct NewPromiseView_Previews: PreviewProvider {
    static var previews: some View {
        NewPromiseView()
            .environmentObject(DataManager())
    }
}
