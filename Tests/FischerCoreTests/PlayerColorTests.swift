import Testing
@testable import FischerCore

final class PlayerColorTests {

    @Test("PlayerColor Initialization")
    func testInit() throws {
        #expect(PlayerColor.init(string: "w") == .white)
        #expect(PlayerColor.init(string: "W") == .white)
        #expect(PlayerColor.init(string: "b") == .black)
        #expect(PlayerColor.init(string: "B") == .black)
        #expect(PlayerColor.init(string: "x") == nil)
    }
    
    @Test("PlayerColor Infix Operator")
    func testInfixOperator() throws {
        #expect(!PlayerColor.white == .black)
        #expect(!PlayerColor.black == .white)
    }
    
    @Test("PlayerColor isWhite")
    func testIsWhite() throws {
        #expect(PlayerColor.white.isWhite())
        #expect(!PlayerColor.black.isWhite())
    }
    
    @Test("PlayerColor isBlack")
    func testIsBlack() throws {
        #expect(PlayerColor.black.isBlack())
        #expect(!PlayerColor.white.isBlack())
    }
    
    @Test("PlayerColor Inverse")
    func testInverse() throws {
        #expect(PlayerColor.white.inverse() == .black)
        #expect(PlayerColor.black.inverse() == .white)
    }
    
    @Test("PlayerColor Invert")
    func testInvert() throws {
        var whiteInverted = PlayerColor.white
        whiteInverted.invert()
        var blackInverted = PlayerColor.black
        blackInverted.invert()
        #expect(whiteInverted == .black)
        #expect(blackInverted == .white)
    }
}
