//
//  LoginView.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

extension Color {
    static let customDarkPurple = Color(hex: "#22092C")
    static let customWine = Color(hex: "#872341")
    static let customRed = Color(hex: "#BE3144")
    static let customOrange = Color(hex: "#F05941")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CustomTextField: View {
    let title: String
    let text: Binding<String>
    let isSecure: Bool
    
    init(_ title: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self.text = text
        self.isSecure = isSecure
        
        UITextField.appearance().tintColor = .white
        UITextField.appearance().textColor = .white
        UITextView.appearance().textColor = .white
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
                    if isSecure {
                        SecureField("", text: text)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white) // Text color while typing
                            .accentColor(.white)     // Cursor color
                            .colorMultiply(.white)   // Ensures consistent color
                            .placeholder(when: text.wrappedValue.isEmpty) {
                                Text(title)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                    } else {
                        TextField("", text: text)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white) // Text color while typing
                            .accentColor(.white)     // Cursor color
                            .colorMultiply(.white)   // Ensures consistent color
                            .placeholder(when: text.wrappedValue.isEmpty) {
                                Text(title)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white.opacity(0.5))
                }
        .padding(.horizontal, 25)
        .padding(.vertical, 10) //added padding for email/password, adjust here
            }
        }

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false  

    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.customWine, .customDarkPurple]),
                startPoint: .leading,
                endPoint: .trailing
                )
            
            VStack(spacing: 32){
                //logo and welcome text
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.customOrange)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "dollarsign.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(15)
                                .foregroundColor(.white)
                        )
                    
                    Text("Welcome back" )
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 60)

                VStack(spacing: 24) {
                    CustomTextField("Your Email", text: $email)
                    
                    CustomTextField("Your Password", text: $password, isSecure: true)
                    
                }
                .padding(.horizontal, 24)
                
                // Action Buttons
                Button {
                    authManager.login(email: email, password: password)
                } label: {
                    Text("Log In")
                        .font(.headline)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(.linearGradient(colors: [.customWine, .customRed], startPoint: .leading, endPoint: .bottomTrailing))
                        )
                        .foregroundStyle(.white)
                }
                .offset(y: 100)
                
                Button {
                    showRegistration.toggle()
                } label: {
                    Text("New user? Create account")
                        .bold()
                        .foregroundStyle(.white)
                }
                .offset(y: 110)
            
            .frame(width: 350)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showRegistration) {
            RegistrationView()
                .environmentObject(authManager)
        }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
