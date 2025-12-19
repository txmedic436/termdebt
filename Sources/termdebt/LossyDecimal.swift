import Foundation

struct LossyDecimal: Decodable {
    let value: Decimal

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self),
            let decimal = Decimal(string: string)
        {
            self.value = decimal
            return
        }

        if let double = try? container.decode(Double.self) {
            self.value = Decimal(double)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid Decimal value"
        )
    }
}
