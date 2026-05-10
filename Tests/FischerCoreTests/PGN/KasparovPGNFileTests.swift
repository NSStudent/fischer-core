import Foundation
import Testing
@testable import FischerCore

final class KasparovPGNFileTests {
    @Test("Kasparov PGN file parses all games")
    func parseKasparovPGNFileFromResources() async throws {
        let fileURL = try #require(
            Bundle.module.url(forResource: "garry-kasparov-on-gk-part-1", withExtension: "pgn")
        )

        let fileContents = try String(contentsOf: fileURL, encoding: .isoLatin1)
        let firstTagIndex = try #require(fileContents.firstIndex(of: "["))
        let pgn = fileContents[firstTagIndex...]
        let eventTagCount = fileContents
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { $0.hasPrefix("[Event ") }
            .count
        let games = try BasicPGNParser().parse(String(pgn))

        #expect(fileContents.contains("% BOOKTITLE = Kasparov on Kasparov 1973-85"))
        #expect(eventTagCount == 137)
        #expect(games.count == 137)
        #expect(games.count == eventTagCount)
        #expect(games.first?.tags[.white] == "About this Publication")
        #expect(games.last?.tags[.event] == "100: World Championship Match, Moscow")
    }
}
