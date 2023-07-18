//
//  EasyCodableContext.swift
//
//
//  Created by 吴哲 on 2023/7/18.
//

/// 上下文信息
public struct EasyCodableContext {
    /// 指定路径
    public let givenPath: Path?
    /// 自动推断路径
    public let inferredPath: Path?
    /// 编码配置信息
    public let options: EasyCodableOptions

    /// 获取路径信息
    public var path: Path {
        switch (givenPath, inferredPath) {
        case let (given?, inferred?):
            return given ?? inferred
        case let (given, inferred):
            return given ?? inferred ?? Path()
        }
    }

    /// 创建上下文
    /// - Parameters:
    ///   - givenPath: 指定路径
    ///   - inferredPath: 推断路径
    ///   - options: 编码信息
    internal init(givenPath: Path? = nil, inferredPath: Path? = nil, options: EasyCodableOptions = .all) {
        self.givenPath = givenPath
        self.inferredPath = inferredPath
        self.options = options
    }

    /// 获取推断路径
    /// - Parameter path: 路径信息
    /// - Returns: 返回一个新的上下文信息
    internal func withInferredPath(_ path: Path?) -> EasyCodableContext {
        EasyCodableContext(givenPath: givenPath, inferredPath: path, options: options)
    }
}

/// 解码扩展选项
public struct EasyCodableOptions: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int

    /// 默认全部
    public static let all: EasyCodableOptions = [.lossy, .snakeCamelConvert]

    /// 集合损耗 过滤null值
    /// `[1, null, 3, null, 5] -> [1, 3, 5]`
    public static let lossy = EasyCodableOptions(rawValue: 1 << 0)

    /// 下划线、驼峰互转
    public static let snakeCamelConvert = EasyCodableOptions(rawValue: 1 << 1)
}
