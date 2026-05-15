//
//  BasicPGNGame.swift
//  FischerCore
//
//  Created by Omar Megdadi on 17/11/25.
//


public struct BasicPGNGame: Equatable, Sendable {
    public var tags: [PGNTag: String]
    public var game: String
    
    public init(tags: [PGNTag : String], game: String) {
        self.tags = tags
        self.game = game
    }

    public subscript(_ tag: PGNTag) -> String? {
        tags[tag]
    }

    public subscript(tagName tagName: String) -> String? {
        tags[PGNTag(rawValue: tagName) ?? .custom(tagName)]
    }

    public var movetext: String {
        game
    }
}

extension BasicPGNGame: Codable {
    private enum CodingKeys: String, CodingKey {
        case tags
        case game
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawTags = try container.decode([String: String].self, forKey: .tags)

        self.init(
            tags: Dictionary(
                rawTags.map { key, value in
                    (PGNTag(rawValue: key) ?? .custom(key), value)
                },
                uniquingKeysWith: { _, newValue in newValue }
            ),
            game: try container.decode(String.self, forKey: .game)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let rawTags = Dictionary(
            tags.map { tag, value in
                (tag.rawValue, value)
            },
            uniquingKeysWith: { _, newValue in newValue }
        )

        try container.encode(rawTags, forKey: .tags)
        try container.encode(game, forKey: .game)
    }
}
