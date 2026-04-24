//
//  PGNGameFENPositionsTests.swift
//  FischerCore
//

import Testing
@testable import FischerCore

final class PGNGameFENPositionsTests {
    @Test("PGN game initializes from empty FEN positions")
    func pgnGameInitializesFromEmptyFenPositions() throws {
        let pgnGame = try PGNGame(fenPositions: [])
        let loadedGame = try Game(loading: pgnGame, moveToEnd: true)

        #expect(try PGNGame.sanRepresentation(fenPositions: []) == "")
        #expect(loadedGame.position.board.fen() == Game().position.board.fen())
    }

    @Test("PGN game initializes from physical board FEN positions")
    func pgnGameInitializesFromPhysicalBoardFenPositions() throws {
        let positions = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
            "rnbqkbnr/pppppppp/8/8/8/8/PPPP1PPP/RNBQKBNR",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKB1R",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R",
            "r1bqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R",
            "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R",
            "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQK2R",
            "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R",
            "r1bqk1nr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R",
            "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R",
            "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ3R",
            "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ2KR",
            "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ2K1",
            "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1",
            "r1bqk2r/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1",
            "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1",
            "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1",
            "r1bq3r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1",
            "r1bq2kr/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1",
            "r1bq2k1/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1",
            "r1bq1rk1/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1",
        ]

        let pgnGame = try PGNGame(fenPositions: positions)
        let loadedGame = try Game(loading: pgnGame, moveToEnd: true)

        #expect(
            try PGNGame.sanRepresentation(fenPositions: positions)
            == "1.e4 e5 2.Nf3 Nc6 3.Bc4 Bc5 4.O-O Nf6 5.d3 O-O"
        )
        #expect(loadedGame.position.board.fen() == positions.last!)
    }

    @Test("PGN game builds SAN representation for promotion FEN positions")
    func pgnGameBuildsSanRepresentationForPromotionFenPositions() throws {
        let knightPromotionPositions = try fenPositions(after: [
            "a2a4",
            "h7h5",
            "a4a5",
            "h5h4",
            "a5a6",
            "h4h3",
            "a6b7",
            "h3g2",
            "b7a8N",
        ])
        let queenPromotionPositions = try fenPositions(after: [
            "a2a4",
            "h7h5",
            "a4a5",
            "h5h4",
            "a5a6",
            "h4h3",
            "a6b7",
            "h3g2",
            "b7a8Q",
        ])

        #expect(
            try PGNGame.sanRepresentation(fenPositions: knightPromotionPositions)
            == "1.a4 h5 2.a5 h4 3.a6 h3 4.axb7 hxg2 5.bxa8=N"
        )
        #expect(
            try PGNGame.sanRepresentation(fenPositions: queenPromotionPositions)
            == "1.a4 h5 2.a5 h4 3.a6 h3 4.axb7 hxg2 5.bxa8=Q"
        )
    }

    @Test("PGN game FEN positions throws typed error for malformed positions")
    func pgnGameFenPositionsThrowsForMalformedPosition() {
        #expect(throws: PGNGameFENPositionsError.self) {
            _ = try PGNGame(fenPositions: ["not-a-fen"])
        }
    }

    @Test("PGN game FEN positions throws typed error for invalid transitions")
    func pgnGameFenPositionsThrowsForInvalidTransition() {
        do {
            _ = try PGNGame(fenPositions: ["8/8/8/8/8/8/8/8"])
            Issue.record("Expected invalid transition error")
        } catch let error as PGNGameFENPositionsError {
            guard case let .invalidMove(index, _, to) = error else {
                Issue.record("Expected invalidMove, got \(error)")
                return
            }
            #expect(index == 0)
            #expect(to == "8/8/8/8/8/8/8/8")
        } catch {
            Issue.record("Expected PGNGameFENPositionsError, got \(error)")
        }
    }

    @Test("PGN game FEN position errors describe each failure")
    func pgnGameFenPositionErrorsDescribeEachFailure() {
        let move = Move(start: .a2, end: .a4)

        #expect(
            PGNGameFENPositionsError.invalidMove(index: 1, from: "start", to: "end").description
            == "Invalid move at index 1: no legal move transforms start into end"
        )
        #expect(
            PGNGameFENPositionsError.moveExecutionFailed(
                index: 2,
                move: move,
                promotion: nil,
                reason: "illegal"
            ).description
            == "Failed to execute move at index 2: a2 >>> a4. illegal"
        )
        #expect(
            PGNGameFENPositionsError.moveExecutionFailed(
                index: 3,
                move: move,
                promotion: .queen,
                reason: "illegal"
            ).description
            == "Failed to execute move at index 3: a2 >>> a4 promoting to Q. illegal"
        )
        #expect(
            PGNGameFENPositionsError.pgnParsingFailed(moveText: "1.e4", reason: "bad").description
            == "Failed to parse generated PGN moves '1.e4'. bad"
        )
    }

    private func fenPositions(after uciMoves: [String]) throws -> [String] {
        var game = Game()
        var positions = [game.position.board.fen()]

        for uciMove in uciMoves {
            let from = String(uciMove.prefix(2))
            let to = String(uciMove.dropFirst(2).prefix(2))
            guard let start = Square(from), let end = Square(to) else {
                Issue.record("Invalid UCI move \(uciMove)")
                continue
            }
            let promotion = uciMove.last.flatMap { PromotionPiece(rawValue: String($0)) }

            if let promotion {
                try game.execute(move: start >>> end, promotion: promotion)
            } else {
                try game.execute(move: start >>> end)
            }
            positions.append(game.position.board.fen())
        }

        return positions
    }
}
