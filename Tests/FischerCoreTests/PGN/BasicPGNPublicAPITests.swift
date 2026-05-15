import Foundation
import FischerCore
import Testing

final class BasicPGNPublicAPITests {
    @Test("Basic PGN reader preserves custom tags and escaped values")
    func basicReaderPreservesCustomTagsAndEscapedValues() throws {
        let input = #"""
        [Event "Rated Bullet game"]
        [Site "https://lichess.org/QYJK65fM"]
        [Rated "true"]
        [Perf "bullet"]
        [Speed "bullet"]
        [GameUrl "https://lichess.org/QYJK65fM"]
        [Link "https://www.chess.com/analysis/game/live/140609505268"]
        [Escaped "escaped \"quote\" and \\ slash"]
        [Result "1-0"]

        1. e4 e5 2. Nf3 Nc6 1-0
        """#

        let games = try BasicPGNReader().parse(input)
        let game = try #require(games.first)

        #expect(games.count == 1)
        #expect(game[.event] == "Rated Bullet game")
        #expect(game[.custom("Rated")] == "true")
        #expect(game[tagName: "Perf"] == "bullet")
        #expect(game[tagName: "Speed"] == "bullet")
        #expect(game[tagName: "GameUrl"] == "https://lichess.org/QYJK65fM")
        #expect(game[.link] == "https://www.chess.com/analysis/game/live/140609505268")
        #expect(game[tagName: "Escaped"] == #"escaped "quote" and \ slash"#)
        #expect(game.movetext.contains("1. e4 e5 2. Nf3 Nc6 1-0"))
    }

    @Test("Basic PGN parser is public without testable import")
    func basicParserIsPublicWithoutTestableImport() throws {
        let input = """
        [Event "Game One"]
        [Result "*"]

        1. e4 e5 *

        [Event "Game Two"]
        [Result "0-1"]

        1. d4 d5 0-1
        """

        let games = try BasicPGNParser().parse(input)

        #expect(games.count == 2)
        #expect(games[0][.event] == "Game One")
        #expect(games[0].game.contains("1. e4 e5 *"))
        #expect(games[1][.event] == "Game Two")
        #expect(games[1].game.contains("1. d4 d5 0-1"))
    }

    @Test("Basic PGN game is equatable and codable")
    func basicGameIsEquatableAndCodable() throws {
        let game = BasicPGNGame(
            tags: [
                .event: "Codable Game",
                .custom("GameUrl"): "https://lichess.org/abcdef"
            ],
            game: "\n\n1. c4 e5 *"
        )

        let encoded = try JSONEncoder().encode(game)
        let decoded = try JSONDecoder().decode(BasicPGNGame.self, from: encoded)

        #expect(decoded == game)
        #expect(decoded[tagName: "GameUrl"] == "https://lichess.org/abcdef")
    }
}
