//
//  EasyCodable.swift
//
//
//  Created by 吴哲 on 2023/7/13.
//

import Foundation

@propertyWrapper
public struct EasyCodable<Value>: Codable {
    /// 执行对象
    var executor: Executor<Value>

    /// 包装值
    public var wrappedValue: Value {
        get {
            return executor.storedValue!
        }
        set {
            if !isKnownUniquelyReferenced(&executor) {
                let newExecutor = Executor<Value>(unsafed: ())
                newExecutor.transferFrom(executor)
                executor = newExecutor
            }
            executor.storedValue = newValue
        }
    }

    @available(*, unavailable, message: "Provide a default value or use optional Type")
    public init() {
        fatalError()
    }

    /// 具体工作由KeyedDecodingContainer处理
    public init(from _: Decoder) throws {
        executor = .init(unsafed: ())
    }

    /// 内部处理 自动处理属性路径
    init(unsafed _: (), inferredPath: Path? = nil) {
        executor = .init(unsafed: (), inferredPath: inferredPath)
    }

    /// 初始化
    /// - Parameters:
    ///   - defaultValue: 默认值
    ///   - executor: 执行配置
    init(defaultValue: Value?, executor: Executor<Value>) {
        self.executor = .init(context: executor.context, transfromer: executor.transformer)
        self.executor.storedValue = defaultValue
    }

    /// encode 工作交给 KeyedEncodingContainer 处理
    public func encode(to _: Encoder) throws {}
}

// MARK: - CustomStringConvertible CustomDebugStringConvertible

extension EasyCodable: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(String(describing: wrappedValue))"
    }

    public var debugDescription: String {
        "\(String(describing: wrappedValue))"
    }
}

// MARK: - Equatable

extension EasyCodable: Equatable where Value: Equatable {
    public static func == (lhs: EasyCodable, rhs: EasyCodable) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public static func == (lhs: Value, rhs: EasyCodable) -> Bool {
        lhs == rhs.wrappedValue
    }

    public static func == (lhs: EasyCodable, rhs: Value) -> Bool {
        lhs.wrappedValue == rhs
    }
}

// MARK: - Comparable

extension EasyCodable: Comparable where Value: Comparable {
    public static func < (lhs: EasyCodable, rhs: EasyCodable) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }

    public static func < (lhs: Value, rhs: EasyCodable) -> Bool {
        lhs < rhs.wrappedValue
    }

    public static func < (lhs: EasyCodable, rhs: Value) -> Bool {
        lhs.wrappedValue < rhs
    }
}

// MARK: - Hashable

extension EasyCodable: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
