//
//  LogoutView.swift
//  HackNotts
//
//  Created by Syed Rudin on 27/10/2024.
//

import SwiftUI

struct LogoutView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding()
                
                Text("Are you sure you want to logout?")
                    .font(.headline)
                
                Button(action: {
                    showConfirmation = true
                }) {
                    Text("Logout")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Logout")
            .alert("Confirm Logout", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

#Preview {
    LogoutView()
}
