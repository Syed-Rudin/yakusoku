//
//  RegistrationView.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.customRed, .customWine]),
                startPoint: .leading,
                endPoint: .trailing
                )
            
            VStack(spacing: 32) {
                //title text
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 24) {
                    CustomTextField("Your Email", text: $email)
                    
                    CustomTextField("Password", text: $password, isSecure: true)
                    
                    CustomTextField("Confirm Password", text: $confirmPassword, isSecure: true)
                    
                }
                
                Button {
                    if password == confirmPassword {
                        authManager.register(email: email, password: password)
                        dismiss() 
                    }
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(.linearGradient(colors: [.customRed, .customOrange], startPoint: .leading, endPoint: .bottomTrailing))
                        )
                        .foregroundStyle(.white)
                }
                .offset(y: 100)
                
                Button {
                    dismiss()  // Close registration sheet
                } label: {
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundStyle(.white)
                }
                .padding(.top)
                .offset(y: 110)
            }
            .frame(width: 350)
        }
        .ignoresSafeArea()
    }
}
#Preview {
    RegistrationView()
        .environmentObject(AuthManager())
}
