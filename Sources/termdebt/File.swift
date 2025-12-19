import Foundation

enum DebtStore {
    static func load(from url: URL) throws -> [Debt] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            let filenameWithExtention = url.lastPathComponent
            throw NSError(
                domain: "File",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "\(filenameWithExtention) not found at \(url.path)"
                ]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder.debtDecoder()
        return try decoder.decode([Debt].self, from: data)
    }

    static func save(_ debts: [Debt], to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(debts)

        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }
}

@available(macOS 11, *)
enum FileLocation {
    static func defaultURL() -> URL {
        #if DEBUG
            return URL("/Users/chriscolpitts/Developer/termdebt/SampleDebts.json")!
        #else
            let path = "~/Library/Application Support/termdebt/debts.json"
            let expanded = NSString(string: path).expandingTildeInPath
            return URL(fileURLWithPath: expanded)
        #endif
    }
}

extension JSONDecoder {
    static func debtDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.nonConformingFloatDecodingStrategy = .throw
        return decoder
    }
}

extension Decimal {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self),
            let decimal = Decimal(string: string)
        {
            self = decimal
            return
        }

        if let double = try? container.decode(Double.self) {
            self = Decimal(double)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid Decimal value"
        )
    }
}
