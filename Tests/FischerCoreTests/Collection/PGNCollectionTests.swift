import Foundation
import Testing
@testable import FischerCore

struct PGNCollectionTests {
    // MARK: - Splitting

    @Test("Splitter returns one chunk per game in real collections", arguments: [
        ("wcup25-short", 120), ("twic1617-short", 100), ("twic1618-short", 159), ("annotated-games", 4)
    ])
    func splitsRealCollections(resource: String, expected: Int) throws {
        let text = try TestResources.text(resource)
        let chunks = PGNGameSplitter.split(text)
        #expect(chunks.count == expected)
        #expect(chunks.allSatisfy { $0.hasPrefix("[Event ") })
        let games = try PGNGameSplitter.chunks(in: Data(text.utf8)).map { try $0.basicGame() }
        #expect(games.count == expected)
        #expect(games.allSatisfy { $0[.event] != nil && !$0.movetext.isEmpty })
    }

    @Test("Splitter keeps byte offsets that point at each game")
    func byteOffsets() throws {
        let data = try TestResources.data("wcup25-short")
        let chunks = PGNGameSplitter.chunks(in: data)
        #expect(chunks.map(\.index) == Array(0..<chunks.count))
        for chunk in chunks.prefix(20) {
            let slice = data[Int(chunk.startByteOffset)..<Int(chunk.endByteOffset)]
            let text = String(decoding: slice, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            #expect(text == chunk.text)
        }
        for (lhs, rhs) in zip(chunks, chunks.dropFirst()) {
            #expect(lhs.endByteOffset == rhs.startByteOffset)
        }
        #expect(chunks.last?.endByteOffset == Int64(data.count))
    }

    @Test("Streaming chunker gives the same games for any block size and can resume")
    func streamingAndResume() throws {
        let data = try TestResources.data("twic1617-short")
        let whole = PGNGameSplitter.chunks(in: data)

        var chunker = PGNByteChunker()
        var streamed: [PGNGameChunk] = []
        var offset = 0
        while offset < data.count {
            let end = min(offset + 997, data.count)
            streamed += chunker.consume(data[offset..<end])
            offset = end
        }
        streamed += chunker.finish()
        #expect(streamed == whole)

        // Resume after the 10th game.
        let resumePoint = whole[9].endByteOffset
        var resumed = PGNByteChunker(startOffset: resumePoint, startIndex: 10)
        let rest = resumed.consume(data[Int(resumePoint)...]) + resumed.finish()
        #expect(rest == Array(whole.dropFirst(10)))
    }

    @Test("Splitter handles CRLF, BOM, Latin-1, missing Event tags and tags inside comments")
    func splitterEdgeCases() throws {
        let text = "\u{FEFF}[White \"A\"]\r\n[Black \"B\"]\r\n\r\n1. e4 { a comment\r\n[%clk 0:01:00] still comment\r\n[Site \"inside\"] } e5 1-0\r\n\r\n[White \"C\"]\r\n\r\n1. d4 *\r\n"
        let chunks = PGNGameSplitter.split(text)
        #expect(chunks.count == 2)
        #expect(chunks[0].hasPrefix("[White \"A\"]\n[Black \"B\"]"))
        #expect(chunks[0].contains("[Site \"inside\"] } e5 1-0"))
        #expect(chunks[1] == "[White \"C\"]\n\n1. d4 *")

        var latin1 = Data("[Event \"Caf".utf8)
        latin1.append(0xE9) // é in Latin-1, invalid UTF-8
        latin1.append(contentsOf: Array("\"]\n\n1. e4 *\n".utf8))
        let decoded = PGNGameSplitter.chunks(in: latin1)
        #expect(decoded.first?.text.hasPrefix("[Event \"Café\"]") == true)

        let broken = "[Event \"One\"]\n\n1. e4 { never closed\n\n[Event \"Two\"]\n\n1. d4 *\n"
        #expect(PGNGameSplitter.split(broken).count == 2)
    }

    @Test("Chunks parse into basic and annotated games")
    func chunkParsing() throws {
        let chunk = try #require(PGNGameSplitter.chunks(in: TestResources.data("annotated-games")).first)
        #expect(try chunk.basicGame()[.event] == "Annotated study")
        #expect(try chunk.annotatedGame().tree.mainline.count == 25)
    }

    // MARK: - Normalization and hashing

    @Test("Normalized movetext keeps only main line SAN")
    func normalizedMovetext() {
        let text = """
        1.e4 {best by test} e5 (1...c5 2.Nf3 (2.c3)) 2. Nf3! $1 Nc6 ; line comment Bc4
        % escape line 3. h4
        3. Bb5+ a6 4. 0-0 Nf6?! 5.Qe2 1-0
        """
        #expect(PGNNormalization.normalizedMovetext(text) == "e4 e5 Nf3 Nc6 Bb5 a6 O-O Nf6 Qe2")
        #expect(PGNNormalization.normalizedMovetext("1... e5 2. Qh5 *") == "e5 Qh5")
        #expect(PGNNormalization.normalizedMovetext("") == "")
    }

    @Test("Content hash is stable across formatting and annotation differences")
    func contentHashStability() throws {
        let plain = """
        [Event "Club"]
        [Site "?"]
        [Date "2026.01.01"]
        [White "Ana"]
        [Black "Luis"]
        [Result "1-0"]

        1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. O-O Nf6 5. Qe2 1-0
        """
        let annotated = """
        [Black "Luis"]
        [White "ana "]
        [Event "Another event name"]
        [Result "1-0"]
        [Date "2026.01.01"]
        [Annotator "Coach"]

        { Intro } 1.e4 { [%clk 0:05:00] } e5 (1...c5) 2.Nf3 $1 Nc6
        3.Bb5+ a6!? 4.0-0
        Nf6 5.Qe2 1-0
        """.replacingOccurrences(of: "\n", with: "\r\n")
        let lhs = try #require(try BasicPGNParser().parse(plain).first)
        let rhs = try #require(try BasicPGNParser().parse(annotated.replacingOccurrences(of: "\r\n", with: "\n")).first)
        #expect(lhs.contentHash() == rhs.contentHash())
        #expect(lhs.contentHash().count == 16)
        #expect(lhs.normalizedMovetext == rhs.normalizedMovetext)

        // The annotated model hashes like the imported text.
        let game = try AnnotatedPGNGame(pgn: annotated)
        #expect(game.contentHash() == lhs.contentHash())
        // Written and read back, the hash does not change.
        let rewritten = try AnnotatedPGNGame(pgn: game.pgn())
        #expect(rewritten.contentHash() == lhs.contentHash())
    }

    @Test("Content hash changes with moves, players and start position")
    func contentHashDifferences() throws {
        let base = BasicPGNGame(tags: [.white: "Ana", .black: "Luis", .result: "1-0"], game: "1. e4 e5 2. Nf3 1-0")
        let otherMove = BasicPGNGame(tags: base.tags, game: "1. e4 e5 2. Nc3 1-0")
        let otherPlayer = BasicPGNGame(tags: [.white: "Eva", .black: "Luis", .result: "1-0"], game: base.game)
        var fromFEN = base
        fromFEN.tags[.fen] = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 "

        #expect(base.contentHash() != otherMove.contentHash())
        #expect(base.contentHash() != otherPlayer.contentHash())
        #expect(base.contentHash(includeTags: false) == otherPlayer.contentHash(includeTags: false))
        #expect(base.contentHash() != fromFEN.contentHash())
        #expect(PGNNormalization.contentHash(movetext: base.game, tags: base.tags) == base.contentHash())
    }

    @Test("Fallback external ID matches the CCoach algorithm")
    func fallbackExternalID() {
        // FNV-1a 64 of the empty string is the offset basis.
        #expect(PGNHash.fallbackExternalID(for: "") == "cbf29ce484222325")
        #expect(PGNHash.fnv1a64("a".utf8) == 0xaf63dc4c8601ec8c)
        #expect(PGNHash.fnv1a64Hex("a") == "af63dc4c8601ec8c")
        #expect(PGNHash.fallbackExternalID(for: "1. e4 *") == String(PGNHash.fnv1a64("1. e4 *".utf8), radix: 16))
    }
}
