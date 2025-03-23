import Testing
@testable import FischerCore

final class FileTests {

    @Test("File all init")
    func testInit() throws {
        #expect(File("a") == .a)
        #expect(File("b") == .b)
        #expect(File("c") == .c)
        #expect(File("d") == .d)
        #expect(File("e") == .e)
        #expect(File("f") == .f)
        #expect(File("g") == .g)
        #expect(File("h") == .h)
        
        #expect(File(Character("a")) == .a)
        #expect(File(Character("b")) == .b)
        #expect(File(Character("c")) == .c)
        #expect(File(Character("d")) == .d)
        #expect(File(Character("e")) == .e)
        #expect(File(Character("f")) == .f)
        #expect(File(Character("g")) == .g)
        #expect(File(Character("h")) == .h)
        
        #expect(File(index: 7) == .h)
    }

    @Test("File Opposite")
    func testOpposite() throws {
        #expect(File.a.opposite() == .h)
    }

    @Test("File Description")
    func testDescription() throws {
        #expect(File.a.description == "a")
    }

    @Test("File Comparable")
    func testComparable() throws {
        #expect(File.a < .b)
        #expect(!(File.a > .b))
        #expect(!(File.a == .b))
        #expect(File.a == .a)
    }

    @Test("File Index")
    func testIndex() throws {
        #expect(File("a").index == 0)
    }
}
