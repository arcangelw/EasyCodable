//
//  PathEncoder.swift
//
//
//  Created by 吴哲 on 2023/7/20.
//

import Foundation

// swiftlint:disable line_length

enum PathEncoder {
    /// 编码
    /// - Parameters:
    ///   - value: 数据
    ///   - container: 容器
    ///   - pathComponents: 路径组件
    static func encode<T: Encodable>(_ value: T, container: inout KeyedEncodingContainer<PathCodingKey>, pathComponents: [PathComponent]) throws {
        var container = PathEncodingContainer(container: &container)
        for (current, next) in zip(pathComponents, pathComponents.dropFirst()) {
            switch (current, next) {
            case let (.key(key), .key):
                try container.nestedKeyedContainer(forKey: key)
            case let (.key(key), .index):
                try container.nestedUnkeyedContainer(forKey: key)
            case let (.index(index), .key):
                try container.nestedKeyedContainer(at: index)
            case let (.index(index), .index):
                try container.nestedUnkeyedContainer(at: index)
            }
        }
        switch pathComponents.last {
        case let .key(key):
            return try container.encode(value, forKey: key)
        case let .index(index):
            return try container.encode(value, at: index)
        default: throw PathError.invalidPath()
        }
    }
}

// swiftlint:enable line_length

/// 路径编码
private struct PathEncodingContainer {
    /// key-value 容器
    var keyedContainer: KeyedEncodingContainer<PathCodingKey>?
    /// 集合容器
    var unkeyedContainer: UnkeyedEncodingContainer?
    /// 初始化
    init(container: inout KeyedEncodingContainer<PathCodingKey>) {
        keyedContainer = container
    }

    /// 获取key-value 容器
    private func closestKeyedContainer() throws -> KeyedEncodingContainer<PathCodingKey> {
        if let keyedContainer = keyedContainer {
            return keyedContainer
        } else if var unkeyedContainer = unkeyedContainer {
            return unkeyedContainer.nestedContainer(keyedBy: PathCodingKey.self)
        }
        throw PathError.invalidPath()
    }

    /// 获取集合容器
    private func closestUnkeyedContainer() throws -> UnkeyedEncodingContainer {
        if let unkeyedContainer = unkeyedContainer {
            return unkeyedContainer
        }
        throw PathError.invalidPath()
    }

    /// 获取嵌套集合
    mutating func nestedUnkeyedContainer(forKey key: String) throws {
        keyedContainer = nil
        var container = try closestKeyedContainer()
        unkeyedContainer = container.nestedUnkeyedContainer(forKey: .string(key))
    }

    /// 获取嵌套key-value
    mutating func nestedKeyedContainer(forKey key: String) throws {
        unkeyedContainer = nil
        var container = try closestKeyedContainer()
        keyedContainer = container.nestedContainer(keyedBy: PathCodingKey.self, forKey: .string(key))
    }

    /// 获取集合中集合
    mutating func nestedUnkeyedContainer(at _: Int) throws {
        var container = try closestUnkeyedContainer()
        keyedContainer = nil
        unkeyedContainer = container.nestedUnkeyedContainer()
    }

    /// 获取集合中key-value
    mutating func nestedKeyedContainer(at _: Int) throws {
        var container = try closestUnkeyedContainer()
        unkeyedContainer = nil
        keyedContainer = container.nestedContainer(keyedBy: PathCodingKey.self)
    }

    /// 编码key-value取数据
    func encode<T: Encodable>(_ value: T, forKey key: String) throws {
        var container = try closestKeyedContainer()
        try container.encode(value, forKey: .string(key))
    }

    /// 编码集合取数据
    func encode<T: Encodable>(_ value: T, at _: Int) throws {
        var container = try closestUnkeyedContainer()
        try container.encode(value)
    }
}
