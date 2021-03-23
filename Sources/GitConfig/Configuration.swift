public struct Configuration: Equatable, Codable {
    public enum Error: Swift.Error {
        case invalidLine(Int)
    }

    public struct Section: Hashable, Codable {
        public let name: String
        public let settings: [Setting]

        public subscript(_ key: String) -> Value? {
            settings.last(where: { $0.key == key})?.value
        }

        public var isEmpty: Bool {
            return settings.isEmpty
        }
    }

    public struct Setting: Hashable, Codable {
        public let key: String
        public let value: Value
    }

    public enum Value: Hashable {
        case boolean(Bool)
        case integer(Int)
        case string(String)
    }

    // MARK: -

    public let sections: [Section]

    public subscript(_ section: String) -> Section? {
        return sections.last(where: { $0.name == section})
    }

    public var isEmpty: Bool {
        return sections.isEmpty
    }

    public init(_ string: String) throws {
        var sections: [String] = []
        var settings: [String: [Setting]] = [:]

        for (n, line) in string.split(separator: "\n").enumerated() {
            guard !line.isEmpty else { continue }
            guard line.first(where: { !$0.isWhitespace }) != "#"  else { continue }

            if line.hasPrefix("["), line.hasSuffix("]") {
                let startIndex = line.index(after: line.startIndex)
                let endIndex = line.index(before: line.endIndex)
                let section = String(line[startIndex..<endIndex])
                sections.append(section)
            } else {
                guard let section = sections.last,
                      let setting = Setting(String(line))
                else {
                    throw Error.invalidLine(n + 1)
                }

                settings[section, default: []].append(setting)
            }
        }

        self.sections = sections.map({ Section(name: $0, settings: settings[$0, default: []]) })
    }
}

// MARK: - LosslessStringConvertible

extension Configuration.Setting: LosslessStringConvertible {
    public init?(_ description: String) {
        let components = description.split(separator: "=", maxSplits: 1)
        guard components.count == 2,
           let key = components.first?.trimmed,
           let value = components.last?.trimmed
        else { return nil }

        self.init(key: key, value: .init(value))
    }

    public var description: String {
        "\(key) = \(value)"
    }
}

extension Configuration.Value: LosslessStringConvertible {
    public init(_ description: String) {

        switch description.lowercased() {
        case "true":
            self = .boolean(true)
        case "false":
            self = .boolean(false)
        default:
            if let integer = Int(description) {
                self = .integer(integer)
            } else {
                self = .string(description)
            }
        }
    }

    public var description: String {
        switch self {
        case .boolean(true):
            return "true"
        case .boolean(false):
            return "false"
        case .integer(let integer):
            return integer.description
        case .string(let string):
            return string
        }
    }
}

// MARK: - Codable

extension Configuration.Value: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let integer = try? container.decode(Int.self) {
            self = .integer(integer)
        } else {
            let string = try container.decode(String.self)
            self = .string(string)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .boolean(let boolean):
            try container.encode(boolean)
        case .integer(let integer):
            try container.encode(integer)
        case .string(let string):
            try container.encode(string)
        }
    }
}

// MARK: - ExpressibleByBooleanLiteral

extension Configuration.Value: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Configuration.Value: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

// MARK: - ExpressibleByStringLiteral

extension Configuration.Value: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

fileprivate extension StringProtocol {
    var trimmed: String {
        guard let startIndex = firstIndex(where: { !$0.isWhitespace }),
              let endIndex = lastIndex(where: { !$0.isWhitespace })
        else { return "" }

        return String(self[startIndex...endIndex])
    }
}
