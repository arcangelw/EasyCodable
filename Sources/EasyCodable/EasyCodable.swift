//
//  EasyCodable.swift
//
//
//  Created by 吴哲 on 2023/7/13.
//

import Foundation

public protocol EasyCodableStrategy {
    associatedtype Value
    func decode(from decoder: PathDecoder) throws -> Value
}

public struct EasyDecoderOptions: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int
    public static let lossy = EasyDecoderOptions(rawValue: 1 << 0)
}

@propertyWrapper
public struct EasyCodable<Strategy: EasyCodableStrategy> {
    public typealias WrappedValue = Strategy.Value

    public let strategy: Strategy

    public var wrappedValue: WrappedValue

    public init(wrappedValue: WrappedValue, strategy: Strategy) {
        self.wrappedValue = wrappedValue
        self.strategy = strategy
    }
}

extension EasyCodable: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(String(describing: wrappedValue))"
    }

    public var debugDescription: String {
        "\(String(describing: wrappedValue))"
    }
}

extension EasyCodable: Equatable where WrappedValue: Equatable {
    public static func == (lhs: EasyCodable, rhs: EasyCodable) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public static func == (lhs: WrappedValue, rhs: EasyCodable) -> Bool {
        lhs == rhs.wrappedValue
    }

    public static func == (lhs: EasyCodable, rhs: WrappedValue) -> Bool {
        lhs.wrappedValue == rhs
    }
}

extension EasyCodable: Comparable where WrappedValue: Comparable {
    public static func < (lhs: EasyCodable, rhs: EasyCodable) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }

    public static func < (lhs: WrappedValue, rhs: EasyCodable) -> Bool {
        lhs < rhs.wrappedValue
    }

    public static func < (lhs: EasyCodable, rhs: WrappedValue) -> Bool {
        lhs.wrappedValue < rhs
    }
}

extension EasyCodable: Hashable where WrappedValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
