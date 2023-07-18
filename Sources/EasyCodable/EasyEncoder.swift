//
//  EasyEncoder.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation
// swiftlint:disable identifier_name line_length

// MARK: - encodeFinalize 完成具体的编码工作

extension Encodable {

    /// 使用此方法会对所有EasyCodable属性encode
    @discardableResult
    public func container(from encoder: Encoder) throws -> KeyedEncodingContainer<PathCodingKey> {
        var container = encoder.container(keyedBy: PathCodingKey.self)
        for (key, encodable) in encodablePaths {
            try encodable.encodeFinalize(container: &container, forKey: key)
        }
        return container
    }

    private var encodablePaths: [(String, EasyEncodable)] {
        Mirror(reflecting: self).children.compactMap { key, value in
            guard var key = key, let decodable = value as? EasyEncodable else {
                return nil
            }
            if key.hasPrefix("_") {
                key.remove(at: key.startIndex)
            }
            return (key, decodable)
        }
    }
}

private protocol EasyEncodable {
    func encodeFinalize(container: inout KeyedEncodingContainer<PathCodingKey>, forKey key: String) throws
}

extension EasyCodable: EasyEncodable {
    fileprivate func encodeFinalize(container: inout KeyedEncodingContainer<PathCodingKey>, forKey key: String) throws {
        executor.withInferredPath(inferredPath: .init(path: key, noNested: true))
        let value = self
        var encodeValue: Encodable?
        let executor = value.executor
        if let toJSON = executor.transformer?.toJSON {
            if let transformed = toJSON(value.wrappedValue) {
                encodeValue = transformed as? Encodable
            }
        } else if let wrappedValue = value.wrappedValue as? Encodable {
            encodeValue = wrappedValue
        }
        if let encodeValue = encodeValue {
            try container.encode(encodeValue, context: executor.context)
        }
    }
}

extension EasyCodable {
    func encodeFinalize<K: CodingKey>(container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        executor.withInferredPath(inferredPath: .init(path: key.stringValue, noNested: true))
        let value = self
        var encodeValue: Encodable?
        let executor = value.executor
        if let toJSON = executor.transformer?.toJSON {
            if let transformed = toJSON(value.wrappedValue) {
                encodeValue = transformed as? Encodable
            }
        } else if let wrappedValue = value.wrappedValue as? Encodable {
            encodeValue = wrappedValue
        }
        if let encodeValue = encodeValue {
            try container.convertAsPathCodingKey { _container in
                try _container.encode(encodeValue, context: executor.context)
            }
        }
    }
}

// swiftlint:enable identifier_name line_length
