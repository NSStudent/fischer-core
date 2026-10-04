//
//  MoveAnnotations.swift
//  FischerCore
//

import Foundation

/// A comment command that FischerCore does not model explicitly, such as
/// `[%mdl 8]`. It is preserved and written back as is.
public struct PGNCommentCommand: Hashable, Sendable {
    /// The command name without `%`, for example `"mdl"`.
    public var name: String
    /// The raw value, for example `"8"`.
    public var value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

/// An engine evaluation read from a `[%eval]` comment command.
public enum PGNEvaluation: Equatable, Hashable, Sendable, CustomStringConvertible {
    /// An evaluation in pawns from White's point of view, for example `0.17`.
    case pawns(Double)
    /// A forced mate in the given number of moves. Negative values are mates
    /// for Black.
    case mate(Int)

    /// Parses values such as `"0.17"`, `"-1.5"`, `"#3"`, `"#-2"` or
    /// `"0.17,20"` (the depth after the comma is ignored).
    public init?(_ text: String) {
        let value = text.split(separator: ",").first.map(String.init)?.trimmingWhitespace() ?? ""
        if value.hasPrefix("#") {
            guard let moves = Int(value.dropFirst()) else { return nil }
            self = .mate(moves)
        } else {
            guard let pawns = Double(value) else { return nil }
            self = .pawns(pawns)
        }
    }

    public var description: String {
        switch self {
        case let .pawns(value):
            return String(format: "%.2f", value)
        case let .mate(moves):
            return "#\(moves)"
        }
    }
}

/// The annotations attached to a move: NAGs, text comments and the comment
/// commands used by Lichess and ChessBase (`[%csl]`, `[%cal]`, `[%clk]`,
/// `[%emt]`, `[%eval]`).
public struct MoveAnnotations: Equatable, Sendable {
    /// Numeric annotation glyphs, without duplicates, in reading order.
    public var nags: [NAG]

    /// NAG codes outside the standard range (for example ChessBase `$140`),
    /// preserved so they can be written back.
    public var otherNAGCodes: [Int]

    /// Text comments that appear before the move. PGN only places them at the
    /// start of a variation; elsewhere a comment belongs to the previous move.
    public var commentsBefore: [String]

    /// Text comments that follow the move.
    public var comments: [String]

    /// Highlighted squares (`[%csl]`).
    public var squares: [PGNSquare]

    /// Arrows (`[%cal]`).
    public var arrows: [PGNArrow]

    /// Remaining clock time after the move (`[%clk]`), for example `"1:23:45"`.
    public var clock: String?

    /// Time spent on the move (`[%emt]`).
    public var elapsedMoveTime: String?

    /// Engine evaluation after the move (`[%eval]`), raw text.
    public var evaluation: String?

    /// Other comment commands, preserved in reading order.
    public var otherCommands: [PGNCommentCommand]

    public init(
        nags: [NAG] = [],
        otherNAGCodes: [Int] = [],
        commentsBefore: [String] = [],
        comments: [String] = [],
        squares: [PGNSquare] = [],
        arrows: [PGNArrow] = [],
        clock: String? = nil,
        elapsedMoveTime: String? = nil,
        evaluation: String? = nil,
        otherCommands: [PGNCommentCommand] = []
    ) {
        self.nags = []
        self.otherNAGCodes = otherNAGCodes
        self.commentsBefore = commentsBefore
        self.comments = comments
        self.squares = squares
        self.arrows = arrows
        self.clock = clock
        self.elapsedMoveTime = elapsedMoveTime
        self.evaluation = evaluation
        self.otherCommands = otherCommands
        for nag in nags { add(nag) }
    }

    /// Whether there is nothing to write for this move.
    public var isEmpty: Bool {
        nags.isEmpty && otherNAGCodes.isEmpty && commentsBefore.isEmpty && comments.isEmpty
            && squares.isEmpty && arrows.isEmpty && clock == nil && elapsedMoveTime == nil
            && evaluation == nil && otherCommands.isEmpty
    }

    /// Whether any comment command (squares, arrows, clock, time, evaluation
    /// or other) is present.
    public var hasCommands: Bool {
        !squares.isEmpty || !arrows.isEmpty || clock != nil || elapsedMoveTime != nil
            || evaluation != nil || !otherCommands.isEmpty
    }

    /// The text comments after the move joined with a space. Setting it
    /// replaces them with a single comment, or removes them for an empty or
    /// blank string.
    public var commentText: String {
        get { comments.joined(separator: " ") }
        set {
            let normalized = MoveAnnotations.normalizedText(newValue)
            comments = normalized.isEmpty ? [] : [normalized]
        }
    }

    /// The remaining clock time in seconds, parsed from ``clock``.
    public var clockSeconds: TimeInterval? {
        clock.flatMap(MoveAnnotations.seconds(fromClock:))
    }

    /// The move time in seconds, parsed from ``elapsedMoveTime``.
    public var elapsedMoveSeconds: TimeInterval? {
        elapsedMoveTime.flatMap(MoveAnnotations.seconds(fromClock:))
    }

    /// The parsed engine evaluation, if ``evaluation`` is valid.
    public var parsedEvaluation: PGNEvaluation? {
        evaluation.flatMap(PGNEvaluation.init)
    }

    /// The move assessment glyph (`!`, `?`, `!!`, `??`, `!?`, `?!` and the
    /// other codes 1...9), if any.
    public var moveAssessment: NAG? {
        nags.first { MoveAnnotations.moveAssessmentRange.contains($0.rawValue) }
    }

    /// The position assessment glyph (codes 10...21), if any.
    public var positionAssessment: NAG? {
        nags.first { MoveAnnotations.positionAssessmentRange.contains($0.rawValue) }
    }

    /// Adds `nag` unless it is already present.
    public mutating func add(_ nag: NAG) {
        guard nag != .nullAnnotation, !nags.contains(nag) else { return }
        nags.append(nag)
    }

    /// Toggles `nag`. Adding a move or position assessment replaces any other
    /// glyph of the same group, as annotation editors do.
    public mutating func toggle(_ nag: NAG) {
        if let index = nags.firstIndex(of: nag) {
            nags.remove(at: index)
            return
        }
        for range in [MoveAnnotations.moveAssessmentRange, MoveAnnotations.positionAssessmentRange]
        where range.contains(nag.rawValue) {
            nags.removeAll { range.contains($0.rawValue) }
        }
        add(nag)
    }

    /// Toggles a highlighted square. Toggling the same square with another
    /// color recolors it.
    public mutating func toggleSquare(_ square: Square, color: PGNColor) {
        if let index = squares.firstIndex(where: { $0.square == square }) {
            let existing = squares.remove(at: index)
            if existing.color == color { return }
        }
        squares.append(PGNSquare(color: color, square: square))
    }

    /// Toggles an arrow. Toggling the same arrow with another color recolors it.
    public mutating func toggleArrow(from: Square, to: Square, color: PGNColor) {
        if let index = arrows.firstIndex(where: { $0.fromSquare == from && $0.toSquare == to }) {
            let existing = arrows.remove(at: index)
            if existing.color == color { return }
        }
        arrows.append(PGNArrow(color: color, fromSquare: from, toSquare: to))
    }

    /// The annotations as the comment values used by ``PGNGame`` and
    /// ``PGNElement``, for code written against the 0.3 models.
    public var pgnComments: [PGNComment] {
        var result: [PGNComment] = []
        if !squares.isEmpty { result.append(.squareList(squares)) }
        if !arrows.isEmpty { result.append(.arrowList(arrows)) }
        if let clock { result.append(.clockTime(clock)) }
        if let elapsedMoveTime { result.append(.elapsedMoveTime(elapsedMoveTime)) }
        if let evaluation { result.append(.evaluation(evaluation)) }
        result += comments.map(PGNComment.text)
        return result
    }

    /// Merges `other` into these annotations, skipping values already present.
    public mutating func merge(_ other: MoveAnnotations) {
        other.nags.forEach { add($0) }
        for code in other.otherNAGCodes where !otherNAGCodes.contains(code) { otherNAGCodes.append(code) }
        for text in other.commentsBefore where !commentsBefore.contains(text) { commentsBefore.append(text) }
        for text in other.comments where !comments.contains(text) { comments.append(text) }
        for square in other.squares where !squares.contains(square) { squares.append(square) }
        for arrow in other.arrows where !arrows.contains(arrow) { arrows.append(arrow) }
        clock = clock ?? other.clock
        elapsedMoveTime = elapsedMoveTime ?? other.elapsedMoveTime
        evaluation = evaluation ?? other.evaluation
        for command in other.otherCommands where !otherCommands.contains(command) { otherCommands.append(command) }
    }

    static let moveAssessmentRange = 1...9
    static let positionAssessmentRange = 10...21
}

// MARK: - Reading comment bodies

extension MoveAnnotations {
    /// Collapses runs of whitespace (including line breaks) into one space and
    /// trims the ends.
    static func normalizedText<S: StringProtocol>(_ text: S) -> String {
        text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    /// Parses `H:MM:SS`, `MM:SS` or `SS`, with optional decimals.
    static func seconds(fromClock text: String) -> TimeInterval? {
        let parts = text.trimmingWhitespace().split(separator: ":").map { TimeInterval(String($0)) }
        guard !parts.isEmpty, parts.count <= 3, parts.allSatisfy({ $0 != nil }) else { return nil }
        return parts.compactMap { $0 }.reduce(0) { $0 * 60 + $1 }
    }

    /// Reads one comment body (the text between `{` and `}`), extracting the
    /// `[%command value]` entries anywhere in it and keeping the rest as text.
    mutating func absorbComment<S: StringProtocol>(_ body: S, before: Bool) {
        var text = ""
        var index = body.startIndex
        while index < body.endIndex {
            if body[index] == "[",
               body.index(after: index) < body.endIndex,
               body[body.index(after: index)] == "%",
               let close = body[index...].firstIndex(of: "]") {
                let inner = body[body.index(index, offsetBy: 2)..<close]
                let name = inner.prefix { !$0.isWhitespace }
                let value = MoveAnnotations.normalizedText(inner.dropFirst(name.count))
                absorbCommand(name: String(name), value: value)
                text.append(" ")
                index = body.index(after: close)
                continue
            }
            text.append(body[index])
            index = body.index(after: index)
        }
        let normalized = MoveAnnotations.normalizedText(text)
        guard !normalized.isEmpty else { return }
        if before {
            commentsBefore.append(normalized)
        } else {
            comments.append(normalized)
        }
    }

    private mutating func absorbCommand(name: String, value: String) {
        switch name {
        case "csl":
            squares += value.split(separator: ",").compactMap { item in
                let item = String(item).trimmingWhitespace()
                guard item.count == 3,
                      let color = PGNColor(rawValue: String(item.prefix(1))),
                      let square = Square(String(item.dropFirst())) else { return nil }
                return PGNSquare(color: color, square: square)
            }
        case "cal":
            arrows += value.split(separator: ",").compactMap { item in
                let item = String(item).trimmingWhitespace()
                guard item.count == 5,
                      let color = PGNColor(rawValue: String(item.prefix(1))),
                      let from = Square(String(item.dropFirst().prefix(2))),
                      let to = Square(String(item.suffix(2))) else { return nil }
                return PGNArrow(color: color, fromSquare: from, toSquare: to)
            }
        case "clk":
            clock = value
        case "emt":
            elapsedMoveTime = value
        case "eval":
            evaluation = value
        default:
            otherCommands.append(PGNCommentCommand(name: name, value: value))
        }
    }

    /// Adds a NAG code, keeping unknown codes in ``otherNAGCodes``.
    mutating func addNAGCode(_ code: Int) {
        if let nag = NAG(rawValue: code) {
            add(nag)
        } else if !otherNAGCodes.contains(code) {
            otherNAGCodes.append(code)
        }
    }
}
