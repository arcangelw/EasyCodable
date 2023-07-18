//
//  Path.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

/// 解码路径信息
public struct Path: Hashable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    /// `path1` ?? `path2` 当前 `path1` 会继续从`path2` 获取数据
    /// - Parameters:
    ///   - lhs: 优先路径
    ///   - rhs: 次优先路径
    /// - Returns: 组合路径
    public static func ?? (lhs: Path, rhs: Path) -> Path {
        Path(storage: lhs.storage + rhs.storage)
    }

    /// 拼接路径
    /// - Parameters:
    ///   - lhs: path
    ///   - rhs: path/component
    /// - Returns: 拼接后的路径
    public static func / (lhs: Path, rhs: PathComponentConvertible) -> Path {
        var copy = lhs
        for index in copy.storage.indices {
            copy.storage[index].append(rhs.makePathComponent())
        }
        return copy
    }

    /// 存储路径信息
    private var storage: [[PathComponent]] = [[]]

    /// 获取路径组合信息
    /// - Parameter options: 解码配置 是否需要转换下划线和驼峰
    /// - Returns: 需要解码的组合路径信息
    internal func components(options: EasyCodableOptions) -> [[PathComponent]] {
        guard options.contains(.snakeCamelConvert) else {
            return storage
        }
        var components = storage
        let convertStorage = storage
        for component in convertStorage {
            let convert = component.map(\.snakeCamelConvert)
            if !components.contains(convert) {
                components.append(convert)
            }
        }
        return components
    }

    private init() {}

    /// 通过路径组合创建
    /// - Parameter storage: 组合
    internal init(storage: [[PathComponent]]) {
        self.storage = storage
    }

    /// 通过路径组件创建
    /// - Parameter components: 组件信息
    public init(_ components: PathComponent...) {
        storage = [components]
    }

    /// 通过字符创建
    /// - Parameter value: 路径字符
    public init(stringLiteral value: String) {
        self.init(path: value)
    }

    /// 通过索引创建
    /// - Parameter value: 索引信息
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(.index(value))
    }

    /// 路径信息
    /// - Parameters:
    ///   - path: 路径
    ///   - noNested: 没有嵌套 如果是 `a.b.c -> a/b/c`
    public init(path: String, noNested: Bool = false) {
        guard path.isEmpty == false else {
            self.init()
            return
        }
        if noNested {
            self.init(.key(path))
        } else {
            let components = path.components(separatedBy: ".")
                .map { $0.makePathComponent() }
            self.init()
            storage = [components]
        }
    }

    /// 拼接路径
    /// - Parameter pathComponents: 路径组件
    /// - Returns: 新的路径
    public func appending(_ pathComponents: PathComponentConvertible...) -> Path {
        var copy = self
        for index in copy.storage.indices {
            for component in pathComponents {
                copy.storage[index].append(component.makePathComponent())
            }
        }
        return copy
    }
}

// MARK: - CustomStringConvertible CustomDebugStringConvertible

extension Path: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let componentsDescription = components(options: [.snakeCamelConvert])
            .map { $0.map(\.description).joined(separator: ", ") }
            .map { "[\($0)]" }
            .joined(separator: " OR ")

        return "Path(\(componentsDescription))"
    }

    public var debugDescription: String {
        return description
    }
}
