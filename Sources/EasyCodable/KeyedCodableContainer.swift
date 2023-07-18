//
//  KeyedCodableContainer.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

// swiftlint:disable line_length

// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {

    public func decode<Value>(_ type: EasyCodable<Value>.Type, forKey key: Key) throws -> EasyCodable<Value> {
        return try _decode(type, forKey: key)
    }

    public func decode<Value: Decodable>(_ type: EasyCodable<Value>.Type, forKey key: Key) throws -> EasyCodable<Value> {
        return try _decode(type, forKey: key)
    }

    private func _decode<Value>(_: EasyCodable<Value>.Type, forKey key: Key) throws -> EasyCodable<Value> {
        let wrapper = EasyCodable<Value>(unsafed: (), inferredPath: .init(path: key.stringValue, noNested: true))
        Thread.current.lastInjectionKeeper = InjectionKeeper(codable: wrapper) {
            var mutatingSelf = self
            try? wrapper.decodeFinalize(container: &mutatingSelf, forKey: key)
        }
        return wrapper
    }
}

// MARK: - KeyedEncodingContainer

extension KeyedEncodingContainer {
    public func encode<Value>(_ value: EasyCodable<Value>, forKey key: Key) throws {
        var mutatingSelf = self
        try value.encodeFinalize(container: &mutatingSelf, forKey: key)
    }
}

// swiftlint:enable line_length
