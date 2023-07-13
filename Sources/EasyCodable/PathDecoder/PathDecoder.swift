//
//  PathDecoder.swift
//
//
//  Created by 吴哲 on 2023/7/17.
//

import Foundation

public final class PathDecoder {
    public let decoder: Decoder
    public let options: EasyDecoderOptions

    let pathComponents: [PathComponent]
    let elements: [Element]

    init(decoder: Decoder, pathComponents: [PathComponent], options: EasyDecoderOptions) throws {
        self.decoder = decoder
        self.options = options
        self.pathComponents = pathComponents

        var elements: [Element] = [.decoder(decoder)]

        for (current, next) in zip(pathComponents, pathComponents.dropFirst()) {
            switch (current, next) {
            case let (.key(key), .key):
                try elements.append(
                    .keyed(elements.nestedKeyedContainer(forKey: key))
                )
            case let (.key(key), .index):
                try elements.append(
                    .unkeyed(elements.nestedUnkeyedContainer(forKey: key))
                )
            case let (.index(index), .key):
                try elements.append(
                    .keyed(elements.nestedKeyedContainer(at: index))
                )
            case let (.index(index), .index):
                try elements.append(
                    .unkeyed(elements.nestedUnkeyedContainer(at: index))
                )
            }
        }
        self.elements = elements
    }

    public func decode<T: Decodable>(_: T.Type = T.self) throws -> T {
        switch pathComponents.last {
        case let .key(key):
            return try elements.decode(forKey: key)
        case let .index(index):
            return try elements.decode(at: index)
        case nil:
            return try elements.decode()
        }
    }

    public func unkeyedContainer() throws -> UnkeyedContainer {
        switch pathComponents.last {
        case let .key(key):
            return try elements.nestedUnkeyedContainer(forKey: key)
        case let .index(index):
            return try elements.nestedUnkeyedContainer(at: index)
        case nil:
            return try elements.closestUnkeyedContainer()
        }
    }

    public func keyedContainer() throws -> KeyedContainer {
        switch pathComponents.last {
        case let .key(key):
            return try elements.nestedKeyedContainer(forKey: key)
        case let .index(index):
            return try elements.nestedKeyedContainer(at: index)
        case nil:
            return try elements.closestKeyedContainer()
        }
    }

    public func singleValueContainer() throws -> SingleValueContainer {
        switch pathComponents.last {
        case .key, .index:
            throw PathError.invalidPath()
        case nil:
            return try elements.closestSingleValueContainer()
        }
    }
}
