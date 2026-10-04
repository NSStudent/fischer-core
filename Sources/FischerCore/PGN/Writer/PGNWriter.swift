//
//  PGNWriter.swift
//  FischerCore
//

/// Writes games as PGN text in export format.
///
/// The writer emits the seven tag roster first, adds `FEN` and `SetUp` when
/// the game does not start from the standard position, and writes the move
/// tree with variations, NAGs, comments and comment commands
/// (`[%eval]`, `[%clk]`, `[%emt]`, `[%csl]`, `[%cal]`). A black move gets its
/// `N...` number at the start of a line and after a comment or a variation.
///
/// ```swift
/// let text = PGNWriter().write(game)
/// let compact = PGNWriter(options: .compact).movetext(game.tree, result: .win)
/// ```
public struct PGNWriter: Sendable {
    /// How NAGs are written.
    public enum NAGStyle: Sendable {
        /// `$1`, `$2`… (the PGN export format).
        case numeric
        /// `!`, `?`, `!!`, `??`, `!?`, `?!` glued to the move; other NAGs as `$n`.
        case symbolic
    }

    /// Writer options.
    public struct Options: Sendable {
        /// Maximum line length, or `nil` to write the movetext on one line.
        public var lineLength: Int?
        /// Whether to write variations.
        public var includeVariations: Bool
        /// Whether to write text comments.
        public var includeComments: Bool
        /// Whether to write NAGs.
        public var includeNAGs: Bool
        /// Whether to write comment commands (`[%clk]`, `[%csl]`…).
        public var includeCommands: Bool
        /// How NAGs are written.
        public var nagStyle: NAGStyle
        /// The language of piece letters. PGN files must use English; other
        /// languages are meant for display or sharing as text.
        public var language: SANNotationLanguage

        public init(
            lineLength: Int? = 80,
            includeVariations: Bool = true,
            includeComments: Bool = true,
            includeNAGs: Bool = true,
            includeCommands: Bool = true,
            nagStyle: NAGStyle = .numeric,
            language: SANNotationLanguage = .english
        ) {
            self.lineLength = lineLength
            self.includeVariations = includeVariations
            self.includeComments = includeComments
            self.includeNAGs = includeNAGs
            self.includeCommands = includeCommands
            self.nagStyle = nagStyle
            self.language = language
        }

        /// Export format: everything, lines of at most 80 characters.
        public static let `default` = Options()

        /// Everything on a single line.
        public static let compact = Options(lineLength: nil)

        /// Main line moves only, without annotations.
        public static let mainlineOnly = Options(
            includeVariations: false,
            includeComments: false,
            includeNAGs: false,
            includeCommands: false
        )
    }

    public var options: Options

    public init(options: Options = .default) {
        self.options = options
    }

    // MARK: Games

    /// Writes one game: tag section, blank line and movetext.
    public func write(_ game: AnnotatedPGNGame) -> String {
        var tags = game.tags
        tags[.result] = game.result.rawValue
        if !game.tree.startsFromStandardPosition {
            if tags[.fen] == nil { tags[.fen] = game.tree.initialFEN }
            if tags[.setUp] == nil { tags[.setUp] = "1" }
        }
        return tagSection(tags, order: game.tagOrder) + "\n\n" + movetext(game.tree, result: game.result) + "\n"
    }

    /// Writes several games separated by a blank line.
    public func write(_ games: [AnnotatedPGNGame]) -> String {
        games.map(write).joined(separator: "\n")
    }

    // MARK: Tags

    /// Writes the tag section: the seven tag roster (with default values
    /// for missing tags), then the tags in `order`, then the remaining tags
    /// sorted by name.
    public func tagSection(_ tags: [PGNTag: String], order: [PGNTag] = []) -> String {
        var lines: [String] = []
        var written = Set<PGNTag>()
        for tag in PGNTag.sevenTagRoster {
            lines.append(Self.tagLine(tag, tags[tag] ?? tag.defaultValue))
            written.insert(tag)
        }
        for tag in order where !written.contains(tag) {
            guard let value = tags[tag] else { continue }
            lines.append(Self.tagLine(tag, value))
            written.insert(tag)
        }
        for tag in tags.keys.filter({ !written.contains($0) }).sorted(by: { $0.rawValue < $1.rawValue }) {
            lines.append(Self.tagLine(tag, tags[tag] ?? ""))
        }
        return lines.joined(separator: "\n")
    }

    static func tagLine(_ tag: PGNTag, _ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: " ")
        return "[\(tag.rawValue) \"\(escaped)\"]"
    }

    // MARK: Movetext

    /// Writes the movetext of `tree` followed by the result marker.
    public func movetext(_ tree: AnnotatedMoveTree, result: PGNOutcome?) -> String {
        var atoms: [Atom] = []
        appendComments(for: tree.initialAnnotations, before: false, to: &atoms)
        appendSequence(tree.children, forceNumber: true, to: &atoms)
        if let result {
            atoms.append(.word(result.rawValue))
        }
        return layout(atoms)
    }

    /// Writes the moves of `tree` from the root to `path` as a single line,
    /// for example `"1. e4 e5 2. Nf3"`.
    public func line(_ tree: AnnotatedMoveTree, through path: MovePath) -> String {
        var atoms: [Atom] = []
        for (index, reference) in tree.line(through: path).enumerated() {
            atoms.append(.word(moveWord(reference.node, forceNumber: index == 0)))
        }
        return layout(atoms, wraps: false)
    }

    private enum Atom {
        /// Text that must not be split.
        case word(String)
        /// A comment block; may be split at spaces.
        case comment(String)
    }

    /// Writes a main move with its alternatives and continues along the main
    /// line iteratively.
    private func appendSequence(_ siblings: [AnnotatedMoveNode], forceNumber: Bool, to atoms: inout [Atom]) {
        var siblings = siblings
        var force = forceNumber
        while let main = siblings.first {
            var interrupted = appendMove(main, forceNumber: force, to: &atoms)
            if options.includeVariations {
                for variation in siblings.dropFirst() {
                    atoms.append(.word("("))
                    appendSequence([variation], forceNumber: true, to: &atoms)
                    atoms.append(.word(")"))
                    interrupted = true
                }
            }
            siblings = main.children
            force = interrupted
        }
    }

    /// Appends one move and its annotations.
    ///
    /// - Returns: Whether something was written after the move (a comment),
    ///   which forces a move number on a following black move.
    private func appendMove(_ node: AnnotatedMoveNode, forceNumber: Bool, to atoms: inout [Atom]) -> Bool {
        let before = appendComments(for: node.annotations, before: true, to: &atoms)
        var word = moveWord(node, forceNumber: forceNumber || before)
        var codes: [Int] = []
        if options.includeNAGs {
            codes = node.annotations.nags.map(\.rawValue) + node.annotations.otherNAGCodes
            if options.nagStyle == .symbolic,
               let index = codes.firstIndex(where: { Self.symbol(for: $0) != nil }),
               let symbol = Self.symbol(for: codes[index]) {
                word += symbol
                codes.remove(at: index)
            }
        }
        atoms.append(.word(word))
        for code in codes {
            atoms.append(.word("$\(code)"))
        }
        return appendComments(for: node.annotations, before: false, to: &atoms)
    }

    private func moveWord(_ node: AnnotatedMoveNode, forceNumber: Bool) -> String {
        let san = node.san.description(language: options.language)
        switch node.color {
        case .white:
            return "\(node.moveNumber). \(san)"
        case .black:
            return forceNumber ? "\(node.moveNumber)... \(san)" : san
        }
    }

    /// Appends the comment blocks of `annotations`.
    ///
    /// The commands go first in the block, followed by the first text
    /// comment, so the comment can be read back by any PGN reader. Further
    /// text comments get their own block.
    ///
    /// - Returns: Whether any block was written.
    @discardableResult
    private func appendComments(for annotations: MoveAnnotations, before: Bool, to atoms: inout [Atom]) -> Bool {
        let texts = options.includeComments
            ? (before ? annotations.commentsBefore : annotations.comments).map(Self.escapedComment).filter { !$0.isEmpty }
            : []
        let commands = (!before && options.includeCommands) ? Self.commands(for: annotations) : []
        guard !texts.isEmpty || !commands.isEmpty else { return false }

        var first = commands
        if let text = texts.first { first.append(text) }
        atoms.append(.comment("{ " + first.joined(separator: " ") + " }"))
        for text in texts.dropFirst() {
            atoms.append(.comment("{ " + text + " }"))
        }
        return true
    }

    static func commands(for annotations: MoveAnnotations) -> [String] {
        var commands: [String] = []
        if let evaluation = annotations.evaluation {
            commands.append("[%eval \(escapedCommandValue(evaluation))]")
        }
        if let clock = annotations.clock {
            commands.append("[%clk \(escapedCommandValue(clock))]")
        }
        if let elapsed = annotations.elapsedMoveTime {
            commands.append("[%emt \(escapedCommandValue(elapsed))]")
        }
        if !annotations.squares.isEmpty {
            let squares = annotations.squares.map { "\($0.color.rawValue)\($0.square)" }.joined(separator: ",")
            commands.append("[%csl \(squares)]")
        }
        if !annotations.arrows.isEmpty {
            let arrows = annotations.arrows
                .map { "\($0.color.rawValue)\($0.fromSquare)\($0.toSquare)" }
                .joined(separator: ",")
            commands.append("[%cal \(arrows)]")
        }
        for command in annotations.otherCommands {
            let value = escapedCommandValue(command.value)
            commands.append(value.isEmpty ? "[%\(command.name)]" : "[%\(command.name) \(value)]")
        }
        return commands
    }

    static func escapedComment(_ text: String) -> String {
        MoveAnnotations.normalizedText(
            text.replacingOccurrences(of: "{", with: "(")
                .replacingOccurrences(of: "}", with: ")")
        )
    }

    static func escapedCommandValue(_ text: String) -> String {
        escapedComment(text).replacingOccurrences(of: "]", with: ")")
    }

    static func symbol(for code: Int) -> String? {
        switch code {
        case 1: return "!"
        case 2: return "?"
        case 3: return "!!"
        case 4: return "??"
        case 5: return "!?"
        case 6: return "?!"
        default: return nil
        }
    }

    // MARK: Layout

    private func layout(_ atoms: [Atom], wraps: Bool = true) -> String {
        let limit: Int? = wraps ? options.lineLength : nil
        var words: [String] = []
        for atom in atoms {
            switch atom {
            case let .word(text):
                words.append(text)
            case let .comment(text):
                if limit == nil {
                    words.append(text)
                } else {
                    // A line must not start with `[` (it would look like a
                    // tag) or `%` (an escape line that readers skip), so
                    // such words stay attached to the previous one.
                    var parts: [String] = []
                    for part in text.split(separator: " ").map(String.init) {
                        if let first = part.first, first == "[" || first == "%", let last = parts.popLast() {
                            parts.append(last + " " + part)
                        } else {
                            parts.append(part)
                        }
                    }
                    words += parts
                }
            }
        }

        var text = ""
        var lineCount = 0
        for word in words {
            let separator: String
            if text.isEmpty || word == ")" || text.hasSuffix("(") {
                separator = ""
            } else {
                separator = " "
            }
            if let limit, lineCount > 0, lineCount + separator.count + word.count > limit {
                text += "\n"
                lineCount = 0
                text += word
                lineCount = word.count
                continue
            }
            text += separator + word
            lineCount += separator.count + word.count
        }
        return text
    }
}

public extension PGNTag {
    /// The seven tag roster required by the PGN standard, in order:
    /// Event, Site, Date, Round, White, Black and Result.
    static let sevenTagRoster: [PGNTag] = [.event, .site, .date, .round, .white, .black, .result]

    /// The value the PGN standard uses for an unknown roster tag: `"?"`,
    /// `"????.??.??"` for dates and `"*"` for the result. Empty for other tags.
    var defaultValue: String {
        switch self {
        case .event, .site, .round, .white, .black: return "?"
        case .date: return "????.??.??"
        case .result: return "*"
        default: return ""
        }
    }
}

public extension Game {
    /// Writes the game as PGN.
    ///
    /// - Parameters:
    ///   - tags: Tags to include. Missing seven tag roster entries get their
    ///     default values; `White` and `Black` default to the game players.
    ///   - result: The result marker. Defaults to the outcome of the game
    ///     (checkmate or stalemate) or `*`.
    ///   - options: Writer options.
    func pgn(tags: [PGNTag: String] = [:], result: PGNOutcome? = nil, options: PGNWriter.Options = .default) -> String {
        AnnotatedPGNGame(game: self, tags: tags, result: result).pgn(options: options)
    }
}
