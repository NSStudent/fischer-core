import Foundation
import Testing
@testable import FischerCore

/// Keeps the 0.4.0 examples of the README compiling and correct.
struct ReadmeExamplesTests {
    @Test("Annotated tree example")
    func annotatedTreeExample() throws {
        var tree = AnnotatedMoveTree()
        let e4 = try tree.insert(san: "e4", at: .root)
        let e5 = try tree.insert(san: "e5", at: e4)
        let c5 = try tree.insert(san: "c5", at: e4)
        tree.updateAnnotations(at: c5) { $0.toggle(.goodMove); $0.commentText = "Sicilian" }
        tree.promote(at: c5)
        #expect(e5 == [0, 0])
        #expect(tree.node(at: [0, 0])?.san.description == "c5")
        #expect(tree.fen(at: [0, 0]) == "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2")
        #expect(tree.allLines.count == 2)
    }

    @Test("Collections and SAN examples")
    func collectionsAndSANExamples() throws {
        let data = try TestResources.data("annotated-games")
        var chunker = PGNByteChunker()
        let chunks = chunker.consume(data) + chunker.finish()
        let basic = try chunks[0].basicGame()
        #expect(basic.contentHash().count == 16)
        #expect(!PGNHash.fallbackExternalID(for: chunks[0].text).isEmpty)

        let game = Game()
        #expect(try game.resolve(san: "Cf3", language: .spanish) == ResolvedMove(move: .g1 >>> .f3))
        #expect(try SANMove(san: "0-0!?", options: .lenient) == .kingsideCastling(isCheck: false, isCheckMate: false))
        #expect(try SANMove(san: "Nxe5+").description(language: .spanish) == "Cxe5+")
        #expect(SANNotationLanguage.spanish.translateToEnglish("Dxd8#") == "Qxd8#")
        #expect(game.legalSANMoves().count == 20)
        var replay = try Game(sanMoves: ["e4", "e5", "Nf3"])
        try replay.replace(ply: 2, with: try SANMove(san: "Bc4"))
        #expect(replay.pgn(tags: [.event: "Club"]).hasSuffix("1. e4 e5 2. Bc4 *\n"))
    }
}
