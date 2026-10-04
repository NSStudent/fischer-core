//
//  PGNGameSplitter.swift
//  FischerCore
//

import Foundation

/// The raw text of one game in a PGN collection.
public struct PGNGameChunk: Equatable, Sendable {
    /// Zero-based position of the game in the collection.
    public let index: Int
    /// The game text, trimmed, with `\n` line endings.
    public let text: String
    /// Byte offset of the first line of the game in the source.
    public let startByteOffset: Int64
    /// Byte offset just after the game: where the next game starts or the
    /// end of the source. Store it to resume an import.
    public let endByteOffset: Int64

    public init(index: Int, text: String, startByteOffset: Int64, endByteOffset: Int64) {
        self.index = index
        self.text = text
        self.startByteOffset = startByteOffset
        self.endByteOffset = endByteOffset
    }

    /// Parses the tag pairs and keeps the movetext as text.
    ///
    /// Unlike ``BasicPGNParser``, the movetext may contain lines that start
    /// with `[` inside comments, because the chunk is known to hold one game.
    public func basicGame() throws -> BasicPGNGame {
        var input = Substring(text)
        let tags = input.first == "[" ? try TagParser().parse(&input) : [:]
        let movetext = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tags.isEmpty || !movetext.isEmpty else {
            throw AnnotatedPGNError.noGame
        }
        return BasicPGNGame(tags: tags, game: movetext)
    }

    /// Reads the game with its annotated move tree.
    public func annotatedGame(strict: Bool = false) throws -> AnnotatedPGNGame {
        try AnnotatedPGNGame(pgn: text, strict: strict)
    }
}

/// Splits PGN collections into the text of each game without parsing moves.
///
/// A new game starts at a tag line (`[Name "value"]`) once the current game
/// already has movetext. Tag-like text inside multi-line `{}` comments does
/// not start a game, except `[Event ` which always does, so one unterminated
/// comment cannot swallow the rest of the file.
public enum PGNGameSplitter {
    /// Splits `text` into the text of each game.
    public static func split(_ text: String) -> [String] {
        chunks(in: Data(text.utf8)).map(\.text)
    }

    /// Splits PGN bytes into games, decoding each line as UTF-8 or, failing
    /// that, Latin-1.
    public static func chunks(in data: Data, startOffset: Int64 = 0) -> [PGNGameChunk] {
        var chunker = PGNByteChunker(startOffset: startOffset)
        return chunker.consume(data) + chunker.finish()
    }
}

/// Splits a PGN byte stream into games incrementally, keeping byte offsets
/// so large imports can be resumed.
///
/// ```swift
/// var chunker = PGNByteChunker()
/// for try await block in fileBlocks {
///     for chunk in chunker.consume(block) { import(chunk) }
/// }
/// for chunk in chunker.finish() { import(chunk) }
/// ```
///
/// To resume, create the chunker with `startOffset` set to the
/// ``PGNGameChunk/endByteOffset`` of the last imported game and feed the
/// file from that offset.
public struct PGNByteChunker: Sendable {
    /// The number of bytes consumed so far, plus the start offset.
    public private(set) var currentOffset: Int64

    private var lineBuffer: [UInt8] = []
    private var lineStartOffset: Int64
    private var currentLines: [String] = []
    private var gameStartOffset: Int64
    private var hasMovetext = false
    private var insideComment = false
    private var nextIndex: Int
    private var isFirstLine = true

    /// Creates a chunker.
    ///
    /// - Parameters:
    ///   - startOffset: The byte offset of the first byte that will be
    ///     consumed.
    ///   - startIndex: The index of the first game produced.
    public init(startOffset: Int64 = 0, startIndex: Int = 0) {
        self.currentOffset = startOffset
        self.lineStartOffset = startOffset
        self.gameStartOffset = startOffset
        self.nextIndex = startIndex
    }

    /// Consumes more bytes and returns the games completed by them.
    public mutating func consume(_ data: Data) -> [PGNGameChunk] {
        var completed: [PGNGameChunk] = []
        for byte in data {
            currentOffset += 1
            if byte == 0x0A {
                if let chunk = consumeLine(endOffset: currentOffset) {
                    completed.append(chunk)
                }
            } else {
                lineBuffer.append(byte)
            }
        }
        return completed
    }

    /// Flushes the last line and game.
    public mutating func finish() -> [PGNGameChunk] {
        var completed: [PGNGameChunk] = []
        if !lineBuffer.isEmpty, let chunk = consumeLine(endOffset: currentOffset) {
            completed.append(chunk)
        }
        if let chunk = flush(endOffset: currentOffset) {
            completed.append(chunk)
        }
        return completed
    }

    private mutating func consumeLine(endOffset: Int64) -> PGNGameChunk? {
        var line = Self.decode(lineBuffer)
        lineBuffer.removeAll(keepingCapacity: true)
        let start = lineStartOffset
        lineStartOffset = endOffset
        if isFirstLine {
            isFirstLine = false
            if line.hasPrefix("\u{FEFF}") { line.removeFirst() }
        }

        var completed: PGNGameChunk?
        let trimmed = line.drop { $0 == " " || $0 == "\t" }
        let isTagLine = trimmed.first == "[" && trimmed.dropFirst().first?.isLetter == true
        let startsGame = isTagLine && hasMovetext && (!insideComment || trimmed.hasPrefix("[Event "))
        if startsGame {
            completed = flush(endOffset: start)
            gameStartOffset = start
            insideComment = false
        }
        if currentLines.isEmpty && line.allSatisfy(\.isWhitespace) {
            gameStartOffset = endOffset
            return completed
        }
        currentLines.append(line)

        if insideComment || !isTagLine {
            if !trimmed.isEmpty && !(trimmed.first == "%" && !insideComment) {
                hasMovetext = true
            }
            scanComments(in: line)
        }
        return completed
    }

    /// Tracks whether a `{}` comment stays open at the end of `line`.
    private mutating func scanComments(in line: String) {
        if !insideComment, line.first == "%" { return }
        for character in line {
            if insideComment {
                if character == "}" { insideComment = false }
            } else if character == "{" {
                insideComment = true
            } else if character == ";" {
                return
            }
        }
    }

    private mutating func flush(endOffset: Int64) -> PGNGameChunk? {
        defer {
            currentLines.removeAll(keepingCapacity: true)
            hasMovetext = false
        }
        let text = currentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        let chunk = PGNGameChunk(index: nextIndex, text: text, startByteOffset: gameStartOffset, endByteOffset: endOffset)
        nextIndex += 1
        return chunk
    }

    static func decode(_ bytes: [UInt8]) -> String {
        var slice = bytes[...]
        if slice.last == 0x0D { slice = slice.dropLast() }
        if let text = String(bytes: slice, encoding: .utf8) {
            return text
        }
        return String(bytes: slice, encoding: .isoLatin1) ?? ""
    }
}
