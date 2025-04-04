//
//  Tag.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//

// Reference https://github.com/fsmosca/PGN-Standard/blob/master/PGN-Standard.txt
public enum PGNTag: String, CaseIterable, Equatable {
    /// Seven Tag Roster
    case event = "Event"
    case site = "Site"
    case date = "Date"
    case round = "Round"
    case white = "White"
    case black = "Black"
    case result = "Result"
    
    // Supplemental tag names
    case whiteTitle = "WhiteTitle"
    case blackTitle = "BlackTitle"
    case whiteElo = "WhiteElo"
    case blackElo = "BlackElo"
    case whiteUSCF = "WhiteUSCF"
    case blackUSCF = "BlackUSCF"
    case whiteNA = "WhiteNA"
    case blackNA = "BlackNA"
    case whiteType = "WhiteType"
    case blackType = "BlackType"
    
    case eventDate = "EventDate"
    case eventSponsor = "EventSponsor"
    case section = "Section"
    case stage = "Stage"
    case board = "Board"
    
    case opening = "Opening"
    case variation = "Variation"
    case subVariation = "SubVariation"
    
    case eco = "ECO"
    case nic = "NIC"
    
    case time = "Time"
    case utcTime = "UTCTime"
    case UTCDate = "UTCDate"
    case timeControl = "TimeControl"
    
    case setUp = "SetUp"
    case fen = "FEN"
    
    case termination = "Termination"
    case annotator = "Annotator"
    case mode = "Mode"
    case plyCount = "PlyCount"

    case variant = "Variant"
    case studyName = "StudyName"
    case chapterName = "ChapterName"
    case whiteFideId = "WhiteFideId"
    case blackFideId = "BlackFideId"

}
