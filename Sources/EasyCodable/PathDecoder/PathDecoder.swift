//
//  PathDecoder.swift
//
//
//  Created by 吴哲 on 2023/7/17.
//

import Foundation

// swiftlint:disable line_length

/// 路径解码
enum PathDecoder {
    /// 解码
    /// - Parameters:
    ///   - _: 类型
    ///   - container: 容器
    ///   - pathComponents: 路径组件
    /// - Returns: 解码值
    static func decode<T: Decodable>(_: T.Type = T.self, container: inout KeyedDecodingContainer<PathCodingKey>, pathComponents: [PathComponent]) throws -> T {
        var container = PathDecodingContainer(container: &container)
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
            return try container.decode(forKey: key)
        case let .index(index):
            return try container.decode(at: index)
        default: throw PathError.invalidPath()
        }
    }
}

// swiftlint:enable line_length

/// 路径解码
private struct PathDecodingContainer {
    /// key-value 容器
    var keyedContainer: KeyedDecodingContainer<PathCodingKey>?
    /// 集合容器
    var unkeyedContainer: UnkeyedDecodingContainer?
    /// 初始化
    init(container: inout KeyedDecodingContainer<PathCodingKey>) {
        keyedContainer = container
    }

    /// 获取key-value 容器
    private func closestKeyedContainer() throws -> KeyedDecodingContainer<PathCodingKey> {
        if let keyedContainer = keyedContainer {
            return keyedContainer
        } else if var unkeyedContainer = unkeyedContainer {
            return try unkeyedContainer.nestedContainer(keyedBy: PathCodingKey.self)
        }
        throw PathError.invalidPath()
    }

    /// 获取集合容器
    private func closestUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        if let unkeyedContainer = unkeyedContainer {
            return unkeyedContainer
        }
        throw PathError.invalidPath()
    }

    /// 获取嵌套集合
    mutating func nestedUnkeyedContainer(forKey key: String) throws {
        keyedContainer = nil
        unkeyedContainer = try closestKeyedContainer().nestedUnkeyedContainer(forKey: .string(key))
    }

    /// 获取嵌套key-value
    mutating func nestedKeyedContainer(forKey key: String) throws {
        unkeyedContainer = nil
        keyedContainer = try closestKeyedContainer().nestedContainer(keyedBy: PathCodingKey.self, forKey: .string(key))
    }

    /// 获取集合中集合
    mutating func nestedUnkeyedContainer(at index: Int) throws {
        var container = try closestUnkeyedContainer()
        keyedContainer = nil
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                unkeyedContainer = try container.nestedUnkeyedContainer()
                return
            } else {
                _ = try container.decode(AnyDecodableValue.self)
            }
        }
        throw PathError.invalidPath()
    }

    /// 获取集合中key-value
    mutating func nestedKeyedContainer(at index: Int) throws {
        var container = try closestUnkeyedContainer()
        unkeyedContainer = nil
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                keyedContainer = try container.nestedContainer(keyedBy: PathCodingKey.self)
                return
            } else {
                _ = try container.decode(AnyDecodableValue.self)
            }
        }
        throw PathError.invalidPath()
    }

    /// 解码key-value取数据
    func decode<T: Decodable>(forKey key: String) throws -> T {
        try closestKeyedContainer().decode(T.self, forKey: .string(key))
    }

    /// 解码集合取数据
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
}
