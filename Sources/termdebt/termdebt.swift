// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct termdebt: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for managing debt",
        usage: "termdebt <command> <options>",
        version: "1.0.0",
        subcommands: [List.self]
    )
}

struct Options: ParsableArguments {
    @Option(
        name: [.customLong("set-locale"), .customShort("l")],
        help: "Set the currency type."
    )
    var customLocale: String? = nil
}

struct List: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "List the debts")
    @OptionGroup var options: Options
    mutating func run() {
        if let locale = options.customLocale {
            print("Locale set to: \(locale)")
        }
        do {
            let debts = try SampleDebtLoader.load()
            debts.forEach {
                print("\($0.name): \($0.principal) @ \($0.apy)%")
            }
        } catch {
            print("Failed to load debts.", error)
        }
    }
}
