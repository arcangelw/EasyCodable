//
//  EasyDecoder.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

// swiftlint:disable identifier_name line_length

// MARK: - decodeFinalize 完成具体的解码工作

extension Decodable {

    /// 使用此方法会对所有EasyCodable属性decode
    @discardableResult
    public func container(from decoder: Decoder) throws -> KeyedDecodingContainer<PathCodingKey> {
        var container = try decoder.container(keyedBy: PathCodingKey.self)
        for (key, decodable) in decodablePaths {
            try decodable.decodeFinalize(container: &container, forKey: key)
        }
        return container
    }

    private var decodablePaths: [(String, EasyDecodable)] {
        Mirror(reflecting: self).children.compactMap { key, value in
            guard var key = key, let decodable = value as? EasyDecodable else {
                return nil
            }
            if key.hasPrefix("_") {
                key.remove(at: key.startIndex)
            }
            return (key, decodable)
        }
    }
}

private protocol EasyDecodable {
    func decodeFinalize(container: inout KeyedDecodingContainer<PathCodingKey>, forKey key: String) throws
}

extension EasyCodable: EasyDecodable {

    fileprivate func decodeFinalize(container: inout KeyedDecodingContainer<PathCodingKey>, forKey key: String) throws {
        executor.withInferredPath(inferredPath: .init(path: key, noNested: true))
        try tryNormalKeyDecode(container: &container)
    }
}

extension EasyCodable {

    func decodeFinalize<K: CodingKey>(container: inout KeyedDecodingContainer<K>, forKey _: KeyedDecodingContainer<K>.Key) throws {
        try container.convertAsPathCodingKey { _container in
            try tryNormalKeyDecode(container: &_container)
        }
    }

    private func tryNormalKeyDecode(container: inout KeyedDecodingContainer<PathCodingKey>) throws {
        do {
            let value = try container.decode(AnyDecodable.self, context: executor.context).value

            if let transformFromJSON = executor.transformer?.fromJSON {
                executor.storedValue = transformFromJSON(value) as? Value
                return
            }

            if let converted = value as? Value {
                executor.storedValue = converted
                return
            }

            if let bridged = (Value.self as? _EasyBuiltInBridgeType.Type)?._transform(from: value), let storedValue = bridged as? Value {
                executor.storedValue = storedValue
                return
            }

            if let valueType = Value.self as? ElementDecodable.Type {
                if let storedValue = try container.decode(valueType.self, context: executor.context) as? Value {
                    executor.storedValue = storedValue
                    return
                }
            }

            if let valueType = Value.self as? Decodable.Type {
                if let storedValue = try container.decode(valueType.self, context: executor.context) as? Value {
                    executor.storedValue = storedValue
                    return
                }
            }
            throw PathError.invalidPath(executor.context.path)
        } catch {
            if let transformFromJSON = executor.transformer?.fromJSON, let transformedNil = transformFromJSON(nil) as? Value {
                executor.storedValue = transformedNil
                return
            }
            throw error
        }
    }
}

// swiftlint:enable identifier_name line_length
