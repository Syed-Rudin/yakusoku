//
//  Contract.swift
//  HackNotts
//
//  Created by Syed Rudin on 26/10/2024.
//

import SwiftUI

struct Contract: Identifiable {
    var id: String
    var name: String
    var description: String
    var amount: Double
    var partnerId: String
    var userId: String
    var dueDate: Date
    var status: ContractStatus
    var completedDate: Date?  // When the partner marked it as success/fail
    
    enum ContractStatus: String, Codable {
        case pending = "pending"
        case success = "success"
        case failed = "failed"
    }
}

// Extension to help with contract status logic
extension Contract {
    var isOverdue: Bool {
        status == .pending && dueDate < Date()
    }
    
    var canBeMarkedAsFailed: Bool {
        status == .pending && dueDate < Date()
    }
    
    var canBeMarkedAsSuccess: Bool {
        status == .pending
    }
    
    var isComplete: Bool {
        status == .success || status == .failed
    }
}

