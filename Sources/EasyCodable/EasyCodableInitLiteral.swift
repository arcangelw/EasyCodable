//
//  EasyCodableInitLiteral.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

// swiftlint:disable force_cast line_length

// MARK: - 提供一些基础数据类型默认值的快速包装

public protocol EasyCodableOptionalProtocol {
    associatedtype Wrapped
}

extension Optional: EasyCodableOptionalProtocol {}

extension EasyCodable: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self.init(literalValue: nil)
    }
}

extension EasyCodable: ExpressibleByArrayLiteral where Value: EasyCodableOptionalProtocol, Value.Wrapped: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Value.Wrapped.ArrayLiteralElement
    private typealias Function = ([ArrayLiteralElement]) -> Value
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        let cast = unsafeBitCast(Value.Wrapped.init(arrayLiteral:), to: Function.self)
        self.init(literalValue: cast(elements))
    }
}

extension EasyCodable: ExpressibleByIntegerLiteral where Value: EasyCodableOptionalProtocol, Value.Wrapped: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Value.Wrapped.IntegerLiteralType) {
        self.init(literalValue: Value.Wrapped(integerLiteral: value) as! Value)
    }
}

extension EasyCodable: ExpressibleByFloatLiteral where Value: EasyCodableOptionalProtocol, Value.Wrapped: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Value.Wrapped.FloatLiteralType) {
        self.init(literalValue: Value.Wrapped(floatLiteral: value) as! Value)
    }
}

extension EasyCodable: ExpressibleByBooleanLiteral where Value: EasyCodableOptionalProtocol, Value.Wrapped: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Value.Wrapped.BooleanLiteralType) {
        self.init(literalValue: Value.Wrapped(booleanLiteral: value) as! Value)
    }
}

extension EasyCodable: ExpressibleByUnicodeScalarLiteral where Value: EasyCodableOptionalProtocol, Value.Wrapped: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: Value.Wrapped.UnicodeScalarLiteralType) {
        self.init(literalValue: Value.Wrapped(unicodeScalarLiteral: value) as! Value)
    }
}

extension EasyCodable: ExpressibleByExtendedGraphemeClusterLiteral where Value: EasyCodableOptionalProtocol, Value.Wrapped: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: Value.Wrapped.ExtendedGraphemeClusterLiteralType) {
        self.init(literalValue: Value.Wrapped(extendedGraphemeClusterLiteral: value) as! Value)
    }
}

extension EasyCodable: ExpressibleByStringLiteral where Value: EasyCodableOptionalProtocol, Value.Wrapped: ExpressibleByStringLiteral {
    public init(stringLiteral value: Value.Wrapped.StringLiteralType) {
        self.init(literalValue: Value.Wrapped(stringLiteral: value) as! Value)
    }
}

extension EasyCodable {
    private init(literalValue: Value) {
        self.init(
            defaultValue: literalValue,
            executor: .init(context: .init(), transfromer: nil)
        )
    }
}

// swiftlint:enable force_cast line_length
