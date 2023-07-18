//
//  PathComponent.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

/// 路径组件信息
public enum PathComponent: Hashable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    case key(String)
    case index(Int)

    public init(stringLiteral value: String) {
        self = .key(value)
    }

    public init(integerLiteral value: Int) {
        self = .index(value)
    }

    internal var snakeCamelConvert: PathComponent {
        if case let .key(key) = self, let key = key.snakeCamelConvert() {
            return .key(key)
        }
        return self
    }
}

// MARK: - CustomStringConvertible CustomDebugStringConvertible

extension PathComponent: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .key(key):
            return "key(\"\(key)\")"
        case let .index(index):
            return "index(\(index))"
        }
    }

    public var debugDescription: String {
        description
    }
}

// MARK: - PathComponentConvertible

/// 路径组件转换
public protocol PathComponentConvertible {
    func makePathComponent() -> PathComponent
}

extension String: PathComponentConvertible {
    public func makePathComponent() -> PathComponent {
        PathComponent(stringLiteral: self)
    }
}

extension Int: PathComponentConvertible {
    public func makePathComponent() -> PathComponent {
        PathComponent(integerLiteral: self)
    }
}

extension PathComponent: PathComponentConvertible {
    public func makePathComponent() -> PathComponent {
        self
    }
}
