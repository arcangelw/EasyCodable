//
//  Decoder+Path.swift
//
//
//  Created by 吴哲 on 2023/7/18.
//

import Foundation

// MARK: - PathCodingKey 解码相关的扩展封装

extension KeyedDecodingContainer<PathCodingKey> {
    mutating func decode<T>(_: T.Type = T.self, context: EasyCodableContext) throws -> T where T: ElementDecodable {
        for components in context.path.components(options: context.options) {
            do {
                return try PathDecoder.decode(container: &self, pathComponents: components)
            } catch {}
        }
        throw PathError.invalidPath(context.path)
    }

    mutating func decode<T>(_: T.Type = T.self, context: EasyCodableContext) throws -> T where T: Decodable {
        for components in context.path.components(options: context.options) {
            do {
                return try PathDecoder.decode(container: &self, pathComponents: components)
            } catch {}
        }
        throw PathError.invalidPath(context.path)
    }
}

// swiftlint:disable line_length

protocol ElementDecodable: Decodable {
    static func decode(container: inout KeyedDecodingContainer<PathCodingKey>, pathComponents: [PathComponent], options: EasyCodableOptions) throws -> Self
}

extension Optional: ElementDecodable where Wrapped: ElementDecodable {
    static func decode(container: inout KeyedDecodingContainer<PathCodingKey>, pathComponents: [PathComponent], options: EasyCodableOptions) throws -> Wrapped? {
        try Wrapped.decode(container: &container, pathComponents: pathComponents, options: options)
    }
}

extension Array: ElementDecodable where Element: Decodable {
    static func decode(container: inout KeyedDecodingContainer<PathCodingKey>, pathComponents: [PathComponent], options: EasyCodableOptions) throws -> [Element] {
        try LossyDecoder.decode(container: &container, pathComponents: pathComponents, options: options)
    }
}

extension Set: ElementDecodable where Element: Decodable {
    static func decode(container: inout KeyedDecodingContainer<PathCodingKey>, pathComponents: [PathComponent], options: EasyCodableOptions) throws -> Set<Element> {
        try LossyDecoder.decode(container: &container, pathComponents: pathComponents, options: options)
    }
}

// swiftlint:enable line_length
