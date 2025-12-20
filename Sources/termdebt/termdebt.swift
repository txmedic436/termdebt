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
        subcommands: [List.self, Add.self, Remove.self]
    )
}

struct LocaleOptions: ParsableArguments {
    @Option(
        name: .long,
        help: "Locale identifier for currency formatting (e.g. en_US, fr_FR)"
    )
    var locale: String? = nil
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

struct Remove: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Remove a debt")
    @Argument(help: "Index of debt to remove (see: 'list')") var index: Int
    mutating func run() throws {
        let url = FileLocation.defaultURL()
        var debts = try DebtStore.load(from: url)
        let arrayIndex = index - 1
        guard debts.indices.contains(arrayIndex) else {
            throw ValidationError("Invalid debt index: \(index)")
        }
        let removed = debts.remove(at: arrayIndex)
        try DebtStore.save(debts, to: url)
        print("Removed debt: ", removed.name)
    }
}

struct List: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "List the debts")
    @OptionGroup var localeOptions: LocaleOptions
    mutating func run() {
        let locale: Locale = {
            if let identifier = localeOptions.locale {
                return Locale(identifier: identifier)
            } else {
                return Locale.current
            }
        }()

        let apyFormatter = NumberFormatter()
        apyFormatter.numberStyle = .decimal
        apyFormatter.minimumFractionDigits = 2
        apyFormatter.maximumFractionDigits = 2
        apyFormatter.locale = locale

        do {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = locale

            let url = FileLocation.defaultURL()
            let debts = try DebtStore.load(from: url)

            for (index, debt) in debts.enumerated() {
                ///Formatted principal
                let amount = debt.principal as NSDecimalNumber
                let formattedPrincipal =
                    formatter.string(from: amount) ?? "\(debt.principal)"
                ///Formatted term
                let termDescription: String =
                    debt.term == 0 ? "revolving" : "\(debt.term) mo"
                ///Formatted APY
                let apyNumber = debt.apy as NSDecimalNumber
                let formattedAPY =
                    (apyFormatter.string(from: apyNumber) ?? "\(debt.apy)") + "%"
                //Formatted Indices
                let displayIndex = index + 1
                let indexString = String(format: "%2d.", displayIndex)
                print(
                    "\(indexString) \(debt.name) " + "\(formattedPrincipal) @ \(formattedAPY) "
                        + "term: \(termDescription)"
                )
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
