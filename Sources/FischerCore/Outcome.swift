//
//  Outcome.swift
//  FischerCore
//
//  Created by Omar Megdadi on 13/4/25.
//

import Foundation

public enum Outcome: Hashable, CustomStringConvertible {
        case win(PlayerColor)
        case draw

        public var description: String {
            if let color = winColor {
                return color.isWhite() ? "1-0" : "0-1"
            } else {
                return "1/2-1/2"
            }
        }

        public var winColor: PlayerColor? {
            guard case let .win(color) = self else { return nil }
            return color
        }

        public var isWin: Bool {
            if case .win = self { return true } else { return false }
        }

        public var isDraw: Bool {
            return !isWin
        }

        public init?(_ string: String) {
            let stripped = string.split(separator: " ").map(String.init).joined(separator: "")
            switch stripped {
            case "1-0":
                self = .win(.white)
            case "0-1":
                self = .win(.black)
            case "1/2-1/2":
                self = .draw
            default:
                return nil
            }
        }

        public func value(for playerColor: PlayerColor) -> Double {
            return winColor.map({ $0 == playerColor ? 1 : 0 }) ?? 0.5
        }

    }
