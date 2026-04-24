//
//  Command.swift
//  FischerCore
//

enum Command: Equatable {
    case quit
    case board
    case clear
    case help
    case position
    case reset(fen: String? = nil)
    case move(sans: [String])

    static func match(_ input: String) -> Command? {
        let input = input.split(separator: " ").map(String.init)
        guard let command = input.first else { return nil }

        let args = input.count > 1 ? Array(input.dropFirst()) : []

        switch command {
        case "quit", "q", "exit":
            return .quit
        case "board", "b":
            return .board
        case "clear", "c":
            return .clear
        case "help", "h":
            return .help
        case "position", "p":
            return .position
        case "reset", "r":
            let fen = args.joined(separator: " ")
            return fen.isEmpty ? .reset(fen: nil) : .reset(fen: fen)
        case "move", "m":
            return .move(sans: args)
        default:
            return nil
        }
    }
}
