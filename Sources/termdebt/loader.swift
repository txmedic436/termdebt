import Foundation

enum SampleDebtLoader {
    static func load() throws -> [Debt] {
        let cwd = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: cwd)
            .appendingPathComponent("SampleDebts.json")

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(
                domain: "SampleDebtLoader",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "SampleDebts.json not found at \(url.path)"]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder.debtDecoder()
        return try decoder.decode([Debt].self, from: data)
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
