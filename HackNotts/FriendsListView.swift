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
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                if !searchText.isEmpty {
                    // Search Results
                    List(searchResults) { user in
                        UserRow(user: user)
                    }
                } else {
                    // Alphabetical Friends List
                    List {
                        ForEach(groupedFriends, id: \.0) { section in
                            Section(header: Text(section.0)) {
                                ForEach(section.1) { user in
                                    UserRow(user: user)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
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
                .foregroundColor(.gray)
            
            TextField("Search users...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
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
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if dataManager.isFriend(user.id) {
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "person.badge.minus")
                        .foregroundColor(.red)
                }
            } else {
                Button(action: {
                    dataManager.addFriend(friendId: user.id)
                }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Remove Friend"),
                message: Text("Are you sure you want to remove this friend?"),
                buttons: [
                    .destructive(Text("Remove")) {
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
}
