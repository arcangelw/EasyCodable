//
//  Path.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

public struct Path: Hashable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    public static func ?? (lhs: Path, rhs: Path) -> Path {
        Path(storage: lhs.storage + rhs.storage)
    }

    public static func / (lhs: Path, rhs: PathComponentConvertible) -> Path {
        var copy = lhs
        for index in copy.storage.indices {
            copy.storage[index].append(rhs.makePathComponent())
        }
        return copy
    }

    private var storage: [[PathComponent]] = [[]]

    internal var components: [[PathComponent]] {
        storage
    }

    public static let root = Path()

    private init() {}

    internal init(storage: [[PathComponent]]) {
        self.storage = storage
    }

    public init(_ components: PathComponent...) {
        storage = [components]
    }

    public init(stringLiteral value: String) {
        self.init(path: value)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(.index(value))
    }

    public init(path: String, noNested: Bool = false) {
        guard path.isEmpty == false else {
            self.init()
            return
        }
        if noNested {
            self.init(.key(path))
        } else {
            let components = path.components(separatedBy: ".")
                .map { $0.makePathComponent() }
            self.init()
            storage = [components]
        }
    }

    public func appending(_ pathComponents: PathComponentConvertible...) -> Path {
        var copy = self
        for index in copy.storage.indices {
            for component in pathComponents {
                copy.storage[index].append(component.makePathComponent())
            }
        }
        return copy
    }
}

extension Path: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let componentsDescription = components
            .map { $0.map(\.description).joined(separator: ", ") }
            .map { "[\($0)]" }
            .joined(separator: " OR ")

        return "Path(\(componentsDescription))"
    }

    public var debugDescription: String {
        return description
    }
}
