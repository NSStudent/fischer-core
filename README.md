<div align="center">
    <img src="Fischer-core.png" alt="FischerCore Logo" height="250" />
</div>

# Fischer-core

[![codecov](https://codecov.io/gh/NSStudent/fischer-core/branch/develop/graph/badge.svg?token=XHQP3Y1EHD)](https://codecov.io/gh/NSStudent/fischer-core)

`FischerCore` is a Swift library that encapsulates the core logic and data structures necessary for building chess games.
Named in honor of the legendary chess grandmaster **Bobby Fischer**, this library provides a comprehensive foundation for creating, managing, and enforcing the rules of chess.
It also powers the MindChess project as its chess logic core: https://nsstudent.dev/MindChessLanding/

## What's Included

- `FischerCore`: a Swift library target with board, bitboard, move, game, FEN, SAN, UCI, and PGN support.
- `fischer-cli`: an interactive terminal executable for exploring the engine without writing an app.
- Rule-enforced move execution, including castling, en passant, promotion, check detection, legal move generation, undo, and redo.
- FEN parsing and serialization for `Board`, `Position`, and `Game`.
- Helpers for physical-board and app workflows, including FEN placement extraction, board-placement move resolution, UCI execution, history navigation, structured SAN history, stable renderable piece identity, and game outcome lookup.
- PGN parsing into structured game models, column elements, and move trees.
- Rich PGN comment support, including text, arrows, highlighted squares, clock time, elapsed move time, and engine evaluation annotations.
- SAN and UCI helpers for converting and executing moves.
- Core value types are `Sendable` where their stored state is value-safe, so they can move cleanly through Swift concurrency boundaries.

## Swift Package Manager

You can use `FischerCore` in your project by adding it as a dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/NSStudent/fischer-core.git", from: "0.1.0")
```

Then, add `"FischerCore"` to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "FischerCore", package: "fischer-core")
    ]
)
```

The package exposes both a library product and an executable product:

```swift
.product(name: "FischerCore", package: "fischer-core")
```

```sh
swift run fischer-cli
```

## Documentation

The API reference and detailed documentation for `FischerCore` is available at:

👉 [https://nsstudent.dev/fischer-core/documentation/fischercore/](https://nsstudent.dev/fischer-core/documentation/fischercore/)

You can also generate the DocC documentation locally:

```sh
swift package generate-documentation --target FischerCore
```

To preview the documentation in Xcode, open the package and choose **Product > Build Documentation**.

## Core Usage

Create a game from the standard starting position:

```swift
import FischerCore

var game = Game()

try game.execute(san: "e4")
try game.execute(san: "e5")
try game.execute(san: "Nf3")

print(game.position.fen())
print(try game.sanRepresentation())
```

Create a game from FEN:

```swift
let game = try Game(with: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1")

print(game.board.ascii())
print(game.availableMoves())
```

Work directly with moves:

```swift
var game = Game()
let move = Square.e2 >>> Square.e4

if game.isLegal(move: move) {
    try game.execute(move: move)
}
```

Undo and redo moves:

```swift
var game = Game()

try game.execute(san: "d4")
try game.execute(san: "d5")

let undone = game.undoMove()
let redone = game.redoMove()
```

Generate legal moves for a position:

```swift
let moves = game.availableMoves()
let knightMoves = game.movesBitboardForPiece(at: .g1)
```

## Board, Position, and FEN

`Board` represents piece placement, while `Position` represents the full chess state:

- Piece placement
- Side to move
- Castling rights
- En passant target
- Halfmove clock
- Fullmove number

```swift
let position = Position(fen: "8/8/8/8/8/8/8/4K3 w - - 0 1")
let fen = position?.fen()
```

Useful board helpers include:

- `board.ascii()` for terminal-friendly board rendering.
- `board.fen()` for FEN placement serialization.
- `board.bitboard(for:)` for fast piece/color queries.
- `board.attackers(to:color:)` and `board.attackersToKing(for:)` for attack detection.
- `board.pinned(for:)` for pinned-piece lookup.
- `FEN.placement(from:)` to extract the piece-placement field from either a full FEN string or a placement-only string.

```swift
let placement = FEN.placement(
    from: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
)
// "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR"
```

## App Workflow Helpers

FischerCore includes convenience APIs for common app integrations, especially physical-board, training, replay, and SwiftUI-style views.

Resolve a board-placement change into the legal move that produced it:

```swift
var game = Game()
let nextPlacement = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR"

if let resolved = game.resolvedMove(toPlacement: nextPlacement) {
    try game.execute(resolvedMove: resolved)
}
```

The placement resolver also handles promotions by trying every legal promotion piece and returning the matching `ResolvedMove`:

```swift
let game = try Game(with: "8/k6P/8/8/8/8/K6p/8 w - - 0 1")
let nextPlacement = "7N/k7/8/8/8/8/K6p/8"

let resolved = game.resolvedMove(toPlacement: nextPlacement)
print(resolved?.promotion as Any) // Optional(.knight)
```

Run UCI moves directly when integrating with engines, logs, or network protocols:

```swift
var game = Game()

try game.execute(uci: "e2e4")
try game.execute(uci: "e7e8q")
```

Navigate through played and undone moves without manually looping over `undoMove()` and `redoMove()`:

```swift
game.jumpToMove(8)
game.rewindToStart()
game.fastForward()
```

Use `playedSANMoves()` when a UI needs structured move-list rows instead of one SAN string:

```swift
let rows = try game.playedSANMoves()

for row in rows {
    print(row.moveNumber, row.color, row.san, row.move, row.promotion as Any)
}
```

Render board pieces with stable identities for SwiftUI diffing and animations:

```swift
ForEach(game.boardPieces) { boardPiece in
    PieceView(piece: boardPiece.piece)
        .position(position(for: boardPiece.square))
}
```

Look up the identity for a specific square when a custom renderer needs direct access:

```swift
let pieceID = game.pieceID(at: .e4)
```

Check the finished result directly:

```swift
if let outcome = game.outcome {
    print(outcome)
}
```

## SAN and UCI

FischerCore supports both SAN and UCI-oriented workflows.

Execute SAN directly:

```swift
var game = Game()
try game.execute(san: "e4")
try game.execute(san: "Nf6")
```

Convert UCI to SAN in the current game state:

```swift
var game = Game()

let sanMove = try game.sanMove(from: "e2e4")
try game.execute(move: sanMove)
```

Convert a sequence of UCI moves:

```swift
let sans = try Game().sanMoveList(from: ["e2e4", "e7e5", "g1f3"])
```

Parse UCI move values:

```swift
let value = try UCIMoveValueParser().parse("e7e8q")
print(value.start)
print(value.end)
print(value.promotion)
```

## PGN

Parse PGN text into structured games:

```swift
let pgn = """
[Event "Example"]
[Result "*"]

1. e4 e5 2. Nf3 Nc6 *
"""

let games = try PGNReader().parse(pgn)
let firstGame = games.first
```

Parse into the classic `PGNGame` model:

```swift
let game = try PGNGameParser().parse(pgn)
print(game.tags)
print(game.elements)
print(game.result)
```

Load a parsed PGN game into a rule-enforced `Game`:

```swift
let pgnGame = try PGNGameParser().parse(pgn)
let gameAtStart = try Game(loading: pgnGame)
let gameAtEnd = try Game(loading: pgnGame, moveToEnd: true)
```

Convert a sequence of FEN positions into a PGN game:

```swift
let pgnGame = try PGNGame(fenPositions: [
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
])
```

PGN comments preserve structured annotations:

- Text comments
- Colored arrows (`[%cal ...]`)
- Colored square highlights (`[%csl ...]`)
- Clock time (`[%clk ...]`)
- Elapsed move time (`[%emt ...]`)
- Engine evaluations (`[%eval ...]`)

## Command Line

The FischerCore command line interface can be used to explore and test the package from a terminal.
It is an interactive Noora-powered prompt, so you select commands from a menu instead of typing command aliases manually.

```sh
swift run fischer-cli
```

On startup, the CLI prints the initial board. Each loop then asks you to select one of these commands:

| Command | Description |
| --- | --- |
| `board` | Print the current position as an ASCII chess board. |
| `move` | Prompt for one or more SAN moves separated by spaces, then execute them in order. |
| `position` | Print the current position as a full FEN string. |
| `reset` | Reset to the starting position, or enter a custom FEN position. |
| `clear` | Clear the visible terminal area. |
| `help` | Print the available command list. |
| `quit` | End the FischerCore CLI session. |

Example move input when the CLI asks for SAN notation:

```text
e4 e5 Nf3 Nc6 Bb5
```

Example custom FEN input when using `reset`:

```text
rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1
```

CLI behavior notes:

- Empty reset input restores the standard starting position.
- Invalid FEN input keeps the current game and prints an error.
- Invalid SAN input prints an error for that move.
- Successful moves report the SAN move and the resolved start/end squares.

## Development

Run the test suite:

```sh
swift test
```

Build the library and CLI:

```sh
swift build
```

Generate DocC documentation:

```sh
swift package generate-documentation --target FischerCore
```

The package currently depends on:

- [swift-parsing](https://github.com/pointfreeco/swift-parsing) for parser composition.
- [Noora](https://github.com/tuist/Noora) for the interactive CLI prompts.
- [swift-docc-plugin](https://github.com/apple/swift-docc-plugin) for local documentation generation.

## References

This library is based on the code of other well-crafted chess engines and bitboard libraries in Swift. Notably, it builds upon the work in [Sage by @nvzqz](https://github.com/nvzqz/Sage/tree/develop), adapting and updating it to be compatible with the current state of the Swift language and modern development practices.

## Acknowledgements

Special thanks to [Point-Free](https://www.pointfree.co/) for their fantastic [swift-parsing](https://github.com/pointfreeco/swift-parsing) library, which greatly simplified the implementation of our PGN parser.

## Roadmap

The following features are planned to improve the functionality and completeness of `FischerCore`:

- [x] `BasicPGNParser`
- [x] Tests with some [TWIC](https://theweekinchess.com/twic) pgn files
- [x] Interactive CLI with board, move, position, reset, clear, help, and quit commands
- [x] FEN-to-PGN reconstruction from position sequences
- [x] UCI-to-SAN conversion helpers
- [x] App workflow helpers for physical-board FEN placement resolution, UCI execution, structured SAN history, move-history navigation, and outcome lookup
- [x] `Sendable` conformances for value-safe core model types
- [ ] Add performance benchmarks for parsers and move generation.
- [ ] Improve FEN parsing using a unified parser approach.

### What's Implemented

The following core features are already available:

- `Bitboard & tables`: Dense bitboard representation with precomputed attack masks (king, knight, pawn, lines) for fast move queries and between/line lookup tables.
- `Game`: Rule-enforced move execution (castling, en passant, promotion), move history with undo/redo, outcome detection, threefold/50-move counters, and FEN-based initialization.
- `App helpers`: Resolve a target board placement into a legal move, execute resolved moves or UCI strings, jump through move history, and expose structured SAN rows for move-list UIs.
- `Moves`: `SANMove` <-> `Move` bridge so PGN moves can be executed inside `Game`.
- `UI identity`: Stable `Game.BoardPiece` and `Game.PieceID` values for rendering pieces without relying on string tokens.
- `UCI`: UCI move value parsing and UCI-to-SAN conversion against the current game state.
- `PGN parsing`: Full game parsing into `PGN`, `PGNGame`, `PGNElement`, and `MoveTreePGN` with tags, variations, NAG evaluations, and rich comments.
- `PGN reconstruction`: Build SAN move text and `PGNGame` values from FEN position sequences.
- `Comment types`: Text, arrows, highlighted squares, clock time (`[%clk ...]`), elapsed move time (`[%emt ...]`), and engine evaluation (`[%eval ...]`) comments are parsed and preserved.
