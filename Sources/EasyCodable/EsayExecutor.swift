//
//  StrategyExecutor.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

/// 编码/解码执行
final class Executor<Value> {
    /// 存储上下文
    var context: EasyCodableContext = .init()
    /// 数据类型转换
    var transformer: AnyTransfromer?
    /// 缓存数据
    var storedValue: Value?
    /// 安全有效的初始化
    let safedInit: Bool
    /// 缓存自动获取的路径
    private var inferredPath: Path?

    deinit {
        /// 读取当前线程缓存
        if safedInit, let lastKeeper = Thread.current.lastInjectionKeeper as? InjectionKeeper<Value> {
            lastKeeper.injectBack(self)
            Thread.current.lastInjectionKeeper = nil
        }
    }

    init(unsafed _: (), inferredPath: Path? = nil) {
        safedInit = false
        self.inferredPath = inferredPath
    }

    init(context: EasyCodableContext, transfromer: AnyTransfromer?) {
        safedInit = true
        self.context = context
        transformer = transfromer
    }

    func transferFrom(_ other: Executor<Value>) {
        context = other.context.withInferredPath(inferredPath)
        transformer = other.transformer
        storedValue = other.storedValue
    }

    func withInferredPath(inferredPath: Path) {
        context = context.withInferredPath(inferredPath)
    }
}

/// 通用的transfromer容器
struct AnyTransfromer {
    let hashValue: Int // swiftlint:disable:this legacy_hashing
    let fromJSON: (Any?) -> Any
    let toJSON: (Any) -> Any?

    init<T: TransformType>(_ raw: T) {
        fromJSON = { json in
            raw.transformFromJSON(json as? T.JSON)
        }
        toJSON = { object in
            if let object = object as? T.Object {
                return raw.transformToJSON(object)
            }
            return nil
        }
        hashValue = raw.hashValue()
    }
}

// MARK: - 缓存当前线程顺序执行的编码对象

class InjectionKeeper<Value> {
    private let codable: EasyCodable<Value>
    private let decoding: () -> Void

    init(codable: EasyCodable<Value>, decoding: @escaping () -> Void) {
        self.codable = codable
        self.decoding = decoding
    }

    func injectBack(_ executor: Executor<Value>) {
        codable.executor.transferFrom(executor)
        decoding()
    }
}

private var keeperKey: Void?
private var keyedDecodingContainerKey: Void?

extension Thread {
    var lastInjectionKeeper: AnyObject? {
        set {
            objc_setAssociatedObject(self, &keeperKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &keeperKey) as AnyObject?
        }
    }
}
