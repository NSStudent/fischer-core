//
//  Tag.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//

/// Represents the standardized PGN tags used in chess game notation.
///
/// PGN (Portable Game Notation) tags store metadata about chess games. This enum includes:
/// - The Seven Tag Roster (required PGN tags)
/// - Supplemental tags that offer additional context (e.g., ratings, titles, opening)
///
/// These tags are typically used in headers of PGN files to describe when, where, and how a game was played.

public enum PGNTag: String, CaseIterable, Equatable {
    
    // MARK: - Seven Tag Roster
    /// Name of the event or tournament.
    case event = "Event"
    /// Location where the game was played.
    case site = "Site"
    /// Date the game was played.
    case date = "Date"
    /// Round of the game within the event.
    case round = "Round"
    /// Name of the player with white pieces.
    case white = "White"
    /// Name of the player with black pieces.
    case black = "Black"
    /// Result of the game (e.g., 1-0, 0-1, 1/2-1/2, *).
    case result = "Result"
    
    // MARK: - Supplemental Tags: Titles
    /// Title of the player with white pieces.
    case whiteTitle = "WhiteTitle"
    /// Title of the player with black pieces.
    case blackTitle = "BlackTitle"
    
    // MARK: - Supplemental Tags: Elo Ratings
    /// Elo rating of the player with white pieces.
    case whiteElo = "WhiteElo"
    /// Elo rating of the player with black pieces.
    case blackElo = "BlackElo"
    
    // MARK: - Supplemental Tags: USCF Ratings
    /// USCF rating of the player with white pieces.
    case whiteUSCF = "WhiteUSCF"
    /// USCF rating of the player with black pieces.
    case blackUSCF = "BlackUSCF"
    
    // MARK: - Supplemental Tags: National IDs
    /// National ID of the player with white pieces.
    case whiteNA = "WhiteNA"
    /// National ID of the player with black pieces.
    case blackNA = "BlackNA"
    
    // MARK: - Supplemental Tags: Player Type
    /// Type of the player with white pieces (e.g., human, computer).
    case whiteType = "WhiteType"
    /// Type of the player with black pieces (e.g., human, computer).
    case blackType = "BlackType"
    
    // MARK: - Supplemental Tags: Event Metadata
    /// Date of the event.
    case eventDate = "EventDate"
    /// Sponsor of the event.
    case eventSponsor = "EventSponsor"
    /// Section of the event.
    case section = "Section"
    /// Stage of the event.
    case stage = "Stage"
    /// Board number for the game.
    case board = "Board"
    
    // MARK: - Supplemental Tags: Opening Information
    /// Opening played in the game.
    case opening = "Opening"
    /// Variation of the opening played.
    case variation = "Variation"
    /// Sub-variation of the opening played.
    case subVariation = "SubVariation"
    
    // MARK: - Supplemental Tags: ECO and NIC
    /// ECO code for the opening played.
    case eco = "ECO"
    /// NIC code for the opening played.
    case nic = "NIC"
    
    // MARK: - Supplemental Tags: Time Information
    /// Time control for the game.
    case time = "Time"
    /// UTC time the game was played.
    case utcTime = "UTCTime"
    /// UTC date the game was played.
    case UTCDate = "UTCDate"
    /// Time control format used in the game.
    case timeControl = "TimeControl"
    
    // MARK: - Supplemental Tags: Initial Setup
    /// Indicates if the game is set up from a starting position.
    case setUp = "SetUp"
    /// FEN string representing the position of the game.
    case fen = "FEN"
    
    // MARK: - Supplemental Tags: Game Metadata
    /// Termination of the game (e.g., normal, abandoned).
    case termination = "Termination"
    /// Annotator of the game.
    case annotator = "Annotator"
    /// Mode of the game (e.g., standard, rapid).
    case mode = "Mode"
    /// Total number of plies in the game.
    case plyCount = "PlyCount"

    // MARK: - Supplemental Tags: Variant Information
    /// Variant of the game being played (e.g., chess960).
    case variant = "Variant"
    /// Name of the study related to the game.
    case studyName = "StudyName"
    /// Name of the chapter related to the game.
    case chapterName = "ChapterName"
    /// FIDE ID of the player with white pieces.
    case whiteFideId = "WhiteFideId"
    /// FIDE ID of the player with black pieces.
    case blackFideId = "BlackFideId"
    
    case blackRatingDiff = "BlackRatingDiff"
    case whiteRatingDiff = "WhiteRatingDiff"
    
    // CurrentPosition in chess.com PGN sharing
    case currentPosition = "CurrentPosition"
    case timeZone = "Timezone"
    case ecoUrl = "ECOUrl"
    case startTime = "StartTime"
    case endTime = "EndTime"
    case endDate = "EndDate"
    case link = "Link"
    case whiteUrl = "WhiteUrl"
    case whiteCountry = "WhiteCountry"
    case blackUrl = "BlackUrl"
    case blackCountry = "BlackCountry"

}
