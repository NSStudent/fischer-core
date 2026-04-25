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
}

enum CommandOption: CaseIterable, CustomStringConvertible, Equatable {
    case board
    case move
    case position
    case reset
    case clear
    case help
    case quit

    var description: String {
        switch self {
        case .board:    return "board    — Print the current position as a visual chess board"
        case .move:     return "move     — Execute moves using standard algebraic notation (e.g. e4 Nf3)"
        case .position: return "position — Print the current position as FEN"
        case .reset:    return "reset    — Reset the board, optionally to a custom FEN position"
        case .clear:    return "clear    — Clear the visible area of the console"
        case .help:     return "help     — Print this help message"
        case .quit:     return "quit     — End FischerCore session"
        }
    }
}
