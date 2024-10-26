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
    @State private var partnerId = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contract Details")) {
                    TextField("Contract Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Amount ($)", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Partner ID", text: $partnerId)
                }
                
                Button(action: {
                    dataManager.addContract(
                        name: name,
                        description: description,
                        amount: Double(amount) ?? 0.0,
                        partnerId: partnerId
                    )
                    dismiss()
                }) {
                    Text("Save Contract")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.vertical)
            }
            .navigationTitle("New Contract")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

struct NewContractView_Previews: PreviewProvider {
    static var previews: some View {
        NewContractView()
            .environmentObject(DataManager())
    }
}
