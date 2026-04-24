//
//  PGNGameFENPositionsTests.swift
//  FischerCore
//

import Testing
@testable import FischerCore

final class PGNGameFENPositionsTests {
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
}
