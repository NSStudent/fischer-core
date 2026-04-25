//
//  CLI.swift
//  FischerCore
//

import FischerCore
import Foundation
import Noora

final class CLI {
    private var game: Game
    private let noora: Noora

    init(game: Game = Game(), noora: Noora = Noora()) {
        self.game = game
        self.noora = noora
    }

    func startUp() {
        noora.success("Starting FischerCore CLI")
        write("\n")
        write("\(game.board.ascii())\n\n")
    }

    /// Returns false when the session should end.
    @discardableResult
    func run() -> Bool {
        let option: CommandOption = noora.singleChoicePrompt(
            title: "FischerCore",
            question: "Select a command"
        )

        switch option {
        case .quit:
            noora.success("Goodbye")
            return false

        case .board:
            write("\(game.board.ascii())\n")

        case .clear:
            print("\u{001B}[2J\u{001B}[H", terminator: "")

        case .help:
            for opt in CommandOption.allCases {
                write("  \(opt)\n")
            }
            write("\n")

        case .position:
            write("\(game.position.fen())\n")

        case .reset:
            let fen = noora.textPrompt(
                prompt: "FEN position (leave empty to reset to starting position)",
                description: "Forsyth–Edwards Notation encodes a full chess position as a compact string."
            )
            if fen.isEmpty {
                game = Game()
                noora.success("Board reset")
            } else {
                do {
                    game = try Game(with: fen)
                    noora.success("Board reset")
                } catch {
                    noora.error("Invalid FEN")
                }
            }
            write("\(game.board.ascii())\n")

        case .move:
            let input = noora.textPrompt(
                prompt: "Move(s) in SAN notation",
                description: "Standard Algebraic Notation — separate multiple moves with spaces (e.g. e4 e5 Nf3)."
            )
            let sans = input.split(separator: " ").map(String.init).filter { !$0.isEmpty }
            guard !sans.isEmpty else {
                noora.error("No moves entered")
                break
            }
            for san in sans {
                do {
                    let sanMove = try SANMove(san: san)
                    let move = try game.transform(sanMove: sanMove)
                    try game.execute(move: sanMove)
                    noora.success("Moved \(san) from \(move.start) to \(move.end)")
                } catch {
                    noora.error("Invalid move \(san)")
                }
            }
        }

        return true
    }

    private func write(_ string: String) {
        print(string, terminator: "")
    }
}
