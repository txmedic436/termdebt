// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct termdebt: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A utility for managing debt",
        usage: "termdebt <command> <options>",
        version: "1.0.0",
        subcommands: [List.self, Add.self]
    )
}

struct Options: ParsableArguments {
    @Option(
        name: [.customLong("set-locale"), .customShort("l")],
        help: "Set the currency type."
    )
    var customLocale: String? = nil
}

struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Add a new debt")
    @Argument(help: "Name of the debt") var name: String
    @Argument(help: "Principal amount (e.g. 4200.75)") var principal: Decimal
    @Argument(help: "Annual percentage yield (e.g. 19.99") var apy: Decimal
    @Option(name: .long, help: "Loan term in months (0 for revolving credit)") var term: UInt = 0
    @Option(name: .long, help: "Creation date (ISO-8601). Defaults to now") var created: Date?

    mutating func run() throws {
        let url = FileLocation.defaultURL()
        var debts = try DebtStore.load(from: url)
        let debt = Debt(
            name: name,
            principal: principal,
            apy: apy,
            created: created ?? Date(),
            term: term
        )

        debts.append(debt)
        try DebtStore.save(debts, to: url)
        print("Added debt: ", name)
    }
}

struct List: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "List the debts")
    @OptionGroup var options: Options
    mutating func run() {
        do {
            let url = FileLocation.defaultURL()
            let debts = try DebtStore.load(from: url)
            debts.forEach {
                print("\($0.name): \($0.principal) @ \($0.apy)%")
            }
        } catch {
            print("Failed to load debts.", error)
        }
    }
}

extension Decimal: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(string: argument)
    }
}
