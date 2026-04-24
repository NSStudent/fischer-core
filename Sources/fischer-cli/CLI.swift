//
//  CLI.swift
//  FischerCore
//

import FischerCore
import Foundation
import Noora

final class CLI {
    private let help = """
    USAGE:
      b, board          Print the current position as a visual chess board
      c, clear          Clear the visible area of the console
      m, move <san>...  Execute moves on the board using standard algebraic notation
      h, help           Print this help message
      p, position       Print the current position as FEN
      r, reset [fen]    Reset the board, optionally to a custom FEN position
      q, quit           End FischerCore session

    """

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
        write(help)
        write("\n")
    }

    @discardableResult
    func process(input: String) -> Command? {
        let command = Command.match(input)

        switch command {
        case nil:
            noora.error("Unrecognized command \(input)")

        case .quit:
            noora.success("Goodbye")

        case .board:
            write("\(game.board.ascii())\n")

        case .clear:
            print("\u{001B}[2J\u{001B}[H", terminator: "")

        case .help:
            write(help)

        case .position:
            write("\(game.position.fen())\n")

        case let .reset(fen):
            if let fen {
                do {
                    game = try Game(with: fen)
                    noora.success("Board reset")
                    write("\(game.board.ascii())\n")
                } catch {
                    noora.error("Invalid FEN")
                }
            } else {
                game = Game()
                noora.success("Board reset")
                write("\(game.board.ascii())\n")
            }

        case let .move(sans):
            guard !sans.isEmpty else {
                noora.error("Missing move")
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

        return command
    }

    private func write(_ string: String) {
        print(string, terminator: "")
    }
}
