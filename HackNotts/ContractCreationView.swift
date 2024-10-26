//
//  ContractCreationView.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI

struct ContractCreationView: View {
    @State var task = ""
    @State var accountabilityPartner = ""
    
    var body: some View {
        content
    }
    
    var content: some View {
        ZStack {
            Color.black
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
                .zIndex(0)
            
            VStack(spacing: 20){
                
                Text("Create Contract")
                    .foregroundStyle(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(x: 0, y: -100)
                
                
                TextField("Task", text: $task)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: task.isEmpty) {
                        Text("Task")
                            .foregroundStyle(.white)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                
                TextField("Accountability partner", text: $accountabilityPartner)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: accountabilityPartner.isEmpty) {
                        Text("Accountability partner")
                            .foregroundStyle(.white)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                Button {
                    // Create contract
                } label: {
                    Text("I promise!")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.linearGradient(colors: [.red, .pink], startPoint: .top, endPoint: .bottomTrailing))
                        )
                        .foregroundStyle(.white)
                }
                .padding(.top)
                .offset(y: 100)
            }
            .frame(width: 350)
            

        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContractCreationView()
}


