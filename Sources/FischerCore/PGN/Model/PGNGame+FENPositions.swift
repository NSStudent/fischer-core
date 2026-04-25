//
//  PGNGame+FENPositions.swift
//  FischerCore
//

public enum PGNGameFENPositionsError: Error, CustomStringConvertible, Sendable {
    case malformedPosition(index: Int, fen: String)
    case invalidMove(index: Int, from: String, to: String)
    case moveExecutionFailed(index: Int, move: Move, promotion: PromotionPiece?, reason: String)
    case pgnParsingFailed(moveText: String, reason: String)

    public var description: String {
        switch self {
        case let .malformedPosition(index, fen):
            return "Malformed FEN position at index \(index): \(fen)"
        case let .invalidMove(index, from, to):
            return "Invalid move at index \(index): no legal move transforms \(from) into \(to)"
        case let .moveExecutionFailed(index, move, promotion, reason):
            let promotionText = promotion.map { " promoting to \($0.rawValue)" } ?? ""
            return "Failed to execute move at index \(index): \(move)\(promotionText). \(reason)"
        case let .pgnParsingFailed(moveText, reason):
            return "Failed to parse generated PGN moves '\(moveText)'. \(reason)"
        }
    }
}

public extension PGNGame {
    init(fenPositions positions: [String]) throws {
        let moveText = try Self.sanRepresentation(fenPositions: positions)
        let pgnString = """
        [Event "OTB Game"]
        [Result "*"]

        \(moveText.isEmpty ? "*" : "\(moveText) *")
        """

        do {
            self = try PGNGameParser().parse(pgnString)
        } catch {
            throw PGNGameFENPositionsError.pgnParsingFailed(moveText: moveText, reason: String(describing: error))
        }
    }

    static func sanRepresentation(fenPositions positions: [String]) throws -> String {
        var game = Game()
        for (index, rawPosition) in positions.enumerated() {
            let placement = rawPosition.fenPlacement
            guard Board(fen: placement) != nil else {
                throw PGNGameFENPositionsError.malformedPosition(index: index, fen: rawPosition)
            }
            guard placement != game.position.board.fen() else { continue }
            guard let result = physicalMove(to: placement, in: game) else {
                if index < positions.index(before: positions.endIndex) {
                    continue
                }
                throw PGNGameFENPositionsError.invalidMove(
                    index: index,
                    from: game.position.board.fen(),
                    to: placement
                )
            }

            do {
                if let promotion = result.promotion {
                    try game.execute(move: result.move, promotion: promotion)
                } else {
                    try game.execute(move: result.move)
                }
            } catch {
                throw PGNGameFENPositionsError.moveExecutionFailed(index: index, move: result.move, promotion: result.promotion, reason: String(describing: error))
            }
        }
        return try game.sanRepresentation()
    }
}

private extension PGNGame {
    static func physicalMove(to placement: String, in game: Game) -> (move: Move, promotion: PromotionPiece?)? {
        for move in game.availableMoves() {
            if isPawnPromotion(move: move, in: game) {
                for piece in PromotionPiece.allCases {
                    var next = game
                    try? next.execute(move: move, promotion: piece)
                    if next.position.board.fen() == placement {
                        return (move, piece)
                    }
                }
            } else {
                var next = game
                try? next.execute(move: move)
                if next.position.board.fen() == placement {
                    return (move, nil)
                }
            }
        }
        return nil
    }

    static func isPawnPromotion(move: Move, in game: Game) -> Bool {
        guard let piece = game.board[move.start] else { return false }
        return piece.kind.isPawn && move.end.rank == Rank(endFor: piece.color)
    }
}

private extension String {
    var fenPlacement: String {
        split(separator: " ", maxSplits: 1).first.map(String.init) ?? self
    }
}
