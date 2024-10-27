//
//  FriendsListView.swift
//  HackNotts
//
//  Created by Syed Rudin on 27/10/2024.
//

import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List(dataManager.users) { user in
                HStack {
                    Text(user.name)
                        .font(.headline)
                    Spacer()
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Friends")
            .onAppear {
                dataManager.fetchUsers()
            }
        }
    }
}
#Preview {
    FriendsListView()
}
