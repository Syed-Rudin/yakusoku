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
    @State private var name = ""  // Added name field
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.customRed, .customWine]),
                startPoint: .leading,
                endPoint: .trailing
                )
            
            VStack(spacing: 32) {
                // Logo and welcome text
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.customOrange)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .padding(15)
                                .foregroundColor(.white)
                        )
                    
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 60)
                
                // Form fields
                VStack(spacing: 24) {
                    CustomTextField("Your Email", text: $email)
                    
                    CustomTextField("Full name", text: $name)
                    
                    CustomTextField("Password", text: $password, isSecure: true)
                    
                    CustomTextField("Confirm Password", text: $confirmPassword, isSecure: true)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 10)  //added padding for email/password, adjust here

                // Action buttons
                Button {
                    signUp()
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(.linearGradient(colors: [.customRed, .customOrange], 
                                                      startPoint: .leading, 
                                                      endPoint: .bottomTrailing))
                        )
                }
                .foregroundStyle(.white)
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1 : 0.6)
                .offset(y: 40)
                
                Button {
                    dismiss()
                } label: {
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundStyle(.white)
                }
                .padding(.top)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .ignoresSafeArea()
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !name.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func signUp() {
        if password != confirmPassword {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }
        
        authManager.register(email: email, password: password, name: name) { success, error in
            if let error = error {
                errorMessage = error
                showError = true
            } else if success {
                dismiss()
            }
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthManager())
}
