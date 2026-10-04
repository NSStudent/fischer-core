//
//  FastSANParser.swift
//  FischerCore
//

/// A hand-written SAN parser that accepts exactly the same input as the
/// composed `SanMoveParser`, without the cost of building parser errors on
/// every failed alternative. Used by the PGN readers and ``SANMove/init(san:)``.
enum FastSANParser {
    /// Parses the whole of `text` as exact SAN.
    static func parse<S: StringProtocol>(_ text: S) -> SANMove? {
        var bytes = Array(text.utf8)[...]
        guard !bytes.isEmpty else { return nil }

        var isCheck = false
        var isCheckmate = false
        if bytes.last == UInt8(ascii: "#") {
            isCheckmate = true
            bytes = bytes.dropLast()
        }
        if bytes.last == UInt8(ascii: "+") {
            isCheck = true
            bytes = bytes.dropLast()
        }

        if bytes.elementsEqual("O-O-O".utf8) {
            return .queensideCastling(isCheck: isCheck, isCheckMate: isCheckmate)
        }
        if bytes.elementsEqual("O-O".utf8) {
            return .kingsideCastling(isCheck: isCheck, isCheckMate: isCheckmate)
        }

        var promotion: PromotionPiece?
        if bytes.count >= 2, bytes[bytes.index(bytes.endIndex, offsetBy: -2)] == UInt8(ascii: "=") {
            guard let piece = promotionPiece(bytes.last!) else { return nil }
            promotion = piece
            bytes = bytes.dropLast(2)
        }

        guard let first = bytes.first else { return nil }
        let kind = pieceKind(first)
        var body = kind == nil ? bytes : bytes.dropFirst()
        guard body.count >= 2,
              let destination = square(body[body.index(body.endIndex, offsetBy: -2)], body.last!) else {
            return nil
        }
        body = body.dropLast(2)

        var isCapture = false
        if body.last == UInt8(ascii: "x") {
            isCapture = true
            body = body.dropLast()
        }

        let from: SANMove.FromPosition?
        switch body.count {
        case 0:
            from = nil
        case 1:
            let character = body.first!
            if let file = file(character) {
                from = .file(file)
            } else if kind != nil, let rank = rank(character) {
                from = .rank(rank)
            } else {
                return nil
            }
        case 2 where kind != nil:
            guard let origin = square(body.first!, body.last!) else { return nil }
            from = .square(origin)
        default:
            return nil
        }

        return .san(SANMove.SANDefaultMove(
            piece: kind ?? .pawn,
            from: from,
            isCapture: isCapture,
            toSquare: destination,
            promotionTo: promotion,
            isCheck: isCheck,
            isCheckmate: isCheckmate
        ))
    }

    private static func pieceKind(_ byte: UInt8) -> Piece.Kind? {
        switch byte {
        case UInt8(ascii: "K"): return .king
        case UInt8(ascii: "Q"): return .queen
        case UInt8(ascii: "R"): return .rook
        case UInt8(ascii: "B"): return .bishop
        case UInt8(ascii: "N"): return .knight
        default: return nil
        }
    }

    private static func promotionPiece(_ byte: UInt8) -> PromotionPiece? {
        switch byte {
        case UInt8(ascii: "Q"): return .queen
        case UInt8(ascii: "R"): return .rook
        case UInt8(ascii: "B"): return .bishop
        case UInt8(ascii: "N"): return .knight
        default: return nil
        }
    }

    private static func file(_ byte: UInt8) -> File? {
        guard byte >= UInt8(ascii: "a"), byte <= UInt8(ascii: "h") else { return nil }
        return File(rawValue: Int(byte - UInt8(ascii: "a")) + 1)
    }

    private static func rank(_ byte: UInt8) -> Rank? {
        guard byte >= UInt8(ascii: "1"), byte <= UInt8(ascii: "8") else { return nil }
        return Rank(rawValue: Int(byte - UInt8(ascii: "0")))
    }

    private static func square(_ fileByte: UInt8, _ rankByte: UInt8) -> Square? {
        guard let file = file(fileByte), let rank = rank(rankByte) else { return nil }
        return Square(file: file, rank: rank)
    }
}
