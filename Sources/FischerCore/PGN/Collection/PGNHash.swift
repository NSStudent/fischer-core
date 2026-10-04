//
//  PGNHash.swift
//  FischerCore
//

/// Stable, platform-independent hashes for PGN text.
///
/// Swift's `Hasher` is randomly seeded per process, so it cannot be stored.
/// These functions use 64-bit FNV-1a, which gives the same value on every
/// run and platform.
public enum PGNHash {
    /// The 64-bit FNV-1a hash of `bytes`.
    public static func fnv1a64<Bytes: Sequence>(_ bytes: Bytes) -> UInt64 where Bytes.Element == UInt8 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in bytes {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }

    /// The 64-bit FNV-1a hash of the UTF-8 bytes of `text`, as 16 lowercase
    /// hexadecimal digits.
    public static func fnv1a64Hex(_ text: String) -> String {
        let hex = String(fnv1a64(text.utf8), radix: 16)
        return String(repeating: "0", count: 16 - hex.count) + hex
    }

    /// An identifier for a game without a server ID: the FNV-1a hash of the
    /// raw PGN text, in hexadecimal without padding.
    ///
    /// Matches the identifiers CCoach stored with `fallbackExternalID`. It
    /// changes with any whitespace or tag difference; use
    /// ``PGNNormalization/contentHash(movetext:tags:includeTags:)`` to detect
    /// duplicates.
    public static func fallbackExternalID(for pgn: String) -> String {
        String(fnv1a64(pgn.utf8), radix: 16)
    }
}
