//Debt.swift
// SwiftData model for a debt.
//

import Foundation
import SwiftData

@Model
@available(macOS 15, *)
final class Debt {
    var name: String
    var principal: Decimal
    var apy: Decimal
    var created: Date
    var term: UInt

    init(name: String, principal: Decimal, apy: Decimal, created: Date, term: UInt) {
        self.name = name
        self.principal = principal
        self.apy = apy
        self.created = created
        self.term = term
    }
}
