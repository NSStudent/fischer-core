import Testing
@testable import FischerCore

struct GameLegalityFixesTests {
    @Test("Queenside castling is legal when only the b-file square is attacked")
    func queensideCastlingWithAttackedBFile() throws {
        let game = try Game(with: "1r2k3/8/8/8/8/8/8/R3K3 w Q - 0 1")
        #expect(game.isLegal(move: .e1 >>> .c1))
        #expect(game.legalSANMoves().contains(.queensideCastling(isCheck: false, isCheckMate: false)))
    }

    @Test("Castling through an attacked square stays illegal")
    func castlingThroughAttackedSquare() throws {
        let game = try Game(with: "3rk3/8/8/8/8/8/8/R3K3 w Q - 0 1")
        #expect(!game.isLegal(move: .e1 >>> .c1))
    }

    @Test("A move that escapes check while giving check is detected as check")
    func checkAfterCheckEvasion() throws {
        var game = try Game(with: "3k4/8/8/8/8/3R4/8/K6q w - - 0 1")
        #expect(game.kingIsChecked)
        let san = try game.san(for: ResolvedMove(move: .d3 >>> .d1))
        #expect(san.description == "Rd1+")
        try game.execute(move: .d3 >>> .d1)
        #expect(game.kingIsChecked)
        // Black is in check, so castling-like and unrelated moves are filtered.
        #expect(game.legalMoves().allSatisfy { move in
            var next = game
            try? next.execute(resolvedMove: move)
            return !next.board.attackersToKing(for: .black).isEmpty == false
        })
    }

    @Test("Checkmate and stalemate flags")
    func checkmateAndStalemate() throws {
        let mate = try Game(with: "7k/6Q1/6K1/8/8/8/8/8 b - - 0 1")
        #expect(mate.isCheckmate)
        #expect(!mate.isStalemate)

        let stalemate = try Game(with: "7k/5Q2/6K1/8/8/8/8/8 b - - 0 1")
        #expect(stalemate.isStalemate)
        #expect(!stalemate.isCheckmate)
    }

    @Test("Legal move count from the starting position and a known perft position")
    func legalMoveCounts() throws {
        #expect(Game().legalMoves().count == 20)
        // Kiwipete, perft(1) = 48
        let kiwipete = try Game(with: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1")
        #expect(kiwipete.legalMoves().count == 48)
        // Position 3 from the perft suite, perft(1) = 14
        let position3 = try Game(with: "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1")
        #expect(position3.legalMoves().count == 14)
        // Position 4, perft(1) = 6
        let position4 = try Game(with: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1")
        #expect(position4.legalMoves().count == 6)
    }

    @Test("Perft depth 2 and 3 match the reference values")
    func perftDepth() throws {
        func perft(_ game: Game, _ depth: Int) -> Int {
            guard depth > 0 else { return 1 }
            let moves = game.legalMoves(considerHalfmoves: false)
            if depth == 1 { return moves.count }
            return moves.reduce(0) { total, move in
                var next = game
                try? next.execute(resolvedMove: move, considerHalfmoves: false)
                return total + perft(next, depth - 1)
            }
        }
        #expect(perft(Game(), 3) == 8_902)
        let kiwipete = try Game(with: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1")
        #expect(perft(kiwipete, 2) == 2_039)
        let position3 = try Game(with: "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1")
        #expect(perft(position3, 3) == 2_812)
    }
}
