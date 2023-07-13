//
//  PathDecoder.Element.swift
//
//
//  Created by 吴哲 on 2023/7/17.
//

import Foundation

public extension PathDecoder {
    typealias SingleValueContainer = SingleValueDecodingContainer
    typealias KeyedContainer = KeyedDecodingContainer<PathCodingKey>
    typealias UnkeyedContainer = UnkeyedDecodingContainer
}

extension PathDecoder {
    enum Element {
        case decoder(Decoder)
        case singleValue(SingleValueContainer)
        case unkeyed(UnkeyedContainer)
        case keyed(KeyedContainer)
    }
}

extension Array where Element == PathDecoder.Element {
    // MARK: - Closest containers

    func closestSingleValueContainer() throws -> PathDecoder.SingleValueContainer {
        for element in reversed() {
            switch element {
            case let .decoder(decoder):
                return try decoder.singleValueContainer()
            case let .singleValue(container):
                return container
            case .unkeyed, .keyed:
                continue
            }
        }
        throw PathError.invalidPath()
    }

    func closestUnkeyedContainer() throws -> PathDecoder.UnkeyedContainer {
        for element in reversed() {
            switch element {
            case let .decoder(decoder):
                return try decoder.unkeyedContainer()
            case let .unkeyed(container):
                return container
            case .keyed, .singleValue:
                continue
            }
        }
        throw PathError.invalidPath()
    }

    func closestKeyedContainer() throws -> PathDecoder.KeyedContainer {
        for element in reversed() {
            switch element {
            case let .decoder(decoder):
                return try decoder.container(keyedBy: PathCodingKey.self)
            case var .unkeyed(container):
                return try container.nestedContainer(keyedBy: PathCodingKey.self)
            case let .keyed(container):
                return container
            case .singleValue:
                continue
            }
        }
        throw PathError.invalidPath()
    }

    // MARK: - Keyed access

    func nestedUnkeyedContainer(forKey key: String) throws -> PathDecoder.UnkeyedContainer {
        try closestKeyedContainer().nestedUnkeyedContainer(forKey: .string(key))
    }

    func nestedKeyedContainer(forKey key: String) throws -> PathDecoder.KeyedContainer {
        try closestKeyedContainer().nestedContainer(keyedBy: PathCodingKey.self, forKey: .string(key))
    }

    func decode<T: Decodable>(forKey key: String) throws -> T {
        try closestKeyedContainer().decode(T.self, forKey: .string(key))
    }

    // MARK: - Unkeyed access

    func nestedUnkeyedContainer(at index: Int) throws -> PathDecoder.UnkeyedContainer {
        var container = try closestUnkeyedContainer()
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                return try container.nestedUnkeyedContainer()
            } else {
                _ = try container.decode(AnyDecodableValue.self)
            }
        }
        throw PathError.invalidPath()
    }

    func nestedKeyedContainer(at index: Int) throws -> PathDecoder.KeyedContainer {
        var container = try closestUnkeyedContainer()
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                return try container.nestedContainer(keyedBy: PathCodingKey.self)
            } else {
                _ = try container.decode(AnyDecodableValue.self)
            }
        }
        throw PathError.invalidPath()
    }

    func decode<T: Decodable>(at index: Int) throws -> T {
        var container = try closestUnkeyedContainer()
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                return try container.decode(T.self)
            } else {
                _ = try container.decode(AnyDecodableValue.self)
            }
        }
        throw PathError.invalidPath()
    }

    // MARK: - Direct access

    func nestedUnkeyedContainer() throws -> PathDecoder.UnkeyedContainer {
        var container = try closestUnkeyedContainer()
        return try container.nestedUnkeyedContainer()
    }

    func nestedKeyedContainer() throws -> PathDecoder.KeyedContainer {
        var container = try closestUnkeyedContainer()
        return try container.nestedContainer(keyedBy: PathCodingKey.self)
    }

    func decode<T: Decodable>() throws -> T {
        do {
            var container = try closestUnkeyedContainer()
            return try container.decode(T.self)
        } catch {
            return try closestSingleValueContainer().decode(T.self)
        }
    }
}
