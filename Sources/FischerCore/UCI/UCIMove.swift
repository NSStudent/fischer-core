//
//  UCIMove.swift
//  FischerCore
//
//  Created by Omar Megdadi on 10/11/25.
//


enum UCIMove: Equatable, Sendable {
    case nullMove
    case move(UCIMoveValue)
}
