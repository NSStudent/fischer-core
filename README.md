<div align="center">
    <img src="Fischer-core.png" alt="FischerCore Logo" height="250" />
</div>

# Fischer-core

[![codecov](https://codecov.io/gh/NSStudent/fischer-core/branch/develop/graph/badge.svg?token=XHQP3Y1EHD)](https://codecov.io/gh/NSStudent/fischer-core)

`FischerCore` is a Swift library that encapsulates the core logic and data structures necessary for building chess games.
Named in honor of the legendary chess grandmaster **Bobby Fischer**, this library provides a comprehensive foundation for creating, managing, and enforcing the rules of chess

## Swift Package Manager

You can use `FischerCore` in your project by adding it as a dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/NSStudent/fischer-core.git", from: "0.1.0")
```

Then, add `"FischerCore"` to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "FischerCore", package: "fischer-core")
    ]
)
```

## Documentation

The API reference and detailed documentation for `FischerCore` is available at:

👉 [https://nsstudent.dev/fischer-core/documentation/fischercore/](https://nsstudent.dev/fischer-core/documentation/fischercore/)

## References

This library is based on the code of other well-crafted chess engines and bitboard libraries in Swift. Notably, it builds upon the work in [Sage by @nvzqz](https://github.com/nvzqz/Sage/tree/develop), adapting and updating it to be compatible with the current state of the Swift language and modern development practices.

## Acknowledgements

Special thanks to [Point-Free](https://www.pointfree.co/) for their fantastic [swift-parsing](https://github.com/pointfreeco/swift-parsing) library, which greatly simplified the implementation of our PGN parser.

## Roadmap

The following features are planned to improve the functionality and completeness of `FischerCore`:

- [ ] Support additional PGN comment types (e.g. clock time, evaluation, annotations).
- [ ] Add performance benchmarks for parsers and move generation.
- [ ] Improve FEN parsing using a unified parser approach.

### ✅ What's Implemented

The following core features are already available:

- `Bitboard`: Efficient low-level representation of board state using bitwise operations.
- `Game`: Rule-enforced move execution, undo functionality, outcome detection, and full board state management.
- `PGN parsing`: Conversion of PGN text into structured data with support for tags, comments, and moves.
- `Move`: Encapsulates move logic with origin and destination squares, and supports conversion from `SANMove` to drive game mechanics.