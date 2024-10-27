//
//  FriendsListView.swift
//  HackNotts
//
//  Created by Syed Rudin on 27/10/2024.
//

import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    
    // Group friends by first letter
    var groupedFriends: [(String, [User])] {
        let friendUsers = dataManager.users.filter { user in
            dataManager.isFriend(user.id)
        }
        
        let grouped = Dictionary(grouping: friendUsers) { user in
            String(user.name.prefix(1).uppercased())
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    // Search results
    var searchResults: [User] {
        if searchText.isEmpty {
            return []
        }
        
        let lowercasedQuery = searchText.lowercased()
        
        // First, show friends that match
        let matchingFriends = dataManager.users.filter { user in
            dataManager.isFriend(user.id) &&
            (user.name.lowercased().contains(lowercasedQuery) ||
             user.email.lowercased().contains(lowercasedQuery))
        }
        
        // Then show non-friends that match
        let matchingNonFriends = dataManager.users.filter { user in
            !dataManager.isFriend(user.id) &&
            (user.name.lowercased().contains(lowercasedQuery) ||
             user.email.lowercased().contains(lowercasedQuery))
        }
        
        return matchingFriends + matchingNonFriends
    }
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 0) {
                Text("Friends")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                if !searchText.isEmpty {
                    // Search Results
                    List(searchResults) { user in
                        UserRow(user: user)
                            .listRowInsets(EdgeInsets()) // Remove default padding
                            .listRowBackground(Color.customDarkPurple) // Match background
                            .listRowSeparator(.hidden) // Hide separators
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.customDarkPurple)
                } else {
                    // Alphabetical Friends List
                    List {
                        ForEach(groupedFriends, id: \.0) { section in
                            Section(header: Text(section.0)
                                .foregroundColor(.white)) {
                                ForEach(section.1) { user in
                                    UserRow(user: user)
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.customDarkPurple)
                                        .listRowSeparator(.hidden) 
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.customDarkPurple)
                }
            }
            
                .background(Color.customDarkPurple)
                .onAppear {
                    dataManager.fetchUsers()
                    dataManager.fetchFriends()
                }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.customOrange)
            
            TextField("Search users...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .background(Color.black)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.customRed)
                }
            }
        }
        .background(Color.customDarkPurple)
    }
}

struct UserRow: View {
    let user: User
    @EnvironmentObject var dataManager: DataManager
    @State private var showingActionSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.customOrange)
            }

            
            Spacer()
            
            if dataManager.isFriend(user.id) {
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "person.badge.minus")
                        .foregroundColor(.customRed)
                }
            } else {
                Button(action: {
                    dataManager.addFriend(friendId: user.id)
                }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.customWine)
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.customDarkPurple)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Remove Friend").foregroundColor(.white),
                message: Text("Are you sure you want to remove this friend?").foregroundColor(.white),
                buttons: [
                    .destructive(Text("Remove").foregroundColor(.customRed)) {
                        dataManager.removeFriend(friendId: user.id)
                    },
                    .cancel()
                ]
            )
        }
    }
}

#Preview {
    FriendsListView()
        .environmentObject(DataManager())
        .preferredColorScheme(.dark)
}
