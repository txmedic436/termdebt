//Debt.swift
// SwiftData model for a debt.
//

import Foundation
import SwiftData

struct Debt: Decodable {
    let name: String
    let principal: Decimal
    let apy: Decimal
    let created: Date
    let term: UInt

    private enum CodingKeys: String, CodingKey {
        case name, principal, apy, created, term
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        principal = try container.decode(LossyDecimal.self, forKey: .principal).value
        apy = try container.decode(LossyDecimal.self, forKey: .apy).value
        created = try container.decode(Date.self, forKey: .created)
        term = try container.decode(UInt.self, forKey: .term)
    }
}
