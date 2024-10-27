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
    var isCompleted: Bool
    var userId: String
    var dueDate: Date
}

