//
//  KeyedContainerMap.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

/// 通过一个空字典创建 KeyedDecodingContainer KeyedEncodingContainer事例
/// 获取缓存其内存布局方便类型转换
class KeyedContainerMap {
    static let shared = KeyedContainerMap()

    private var decoderModifier: KeyedDecodingContainerModifier?
    private var encoderModifier: KeyedEncodingContainerModifier?

    init() {
        registerCoder(
            decode: {
                try JSONDecoder().decode(CodablePrepartion.self, from: $0)
            }, encode: {
                try JSONEncoder().encode($0)
            }
        )
    }

    /// 通过一个空字典创建 KeyedDecodingContainer KeyedEncodingContainer 实例
    /// - Parameters:
    ///   - decode: keyedDecodingContainer
    ///   - encode: keyedEncodingContainer
    private func registerCoder(
        decode: (Data) throws -> CodablePrepartion,
        encode: (CodablePrepartion) throws -> Data
    ) {
        let data = Data("{}".utf8)
        do {
            let prepartion = try decode(data)
            registerDecodingContainer(&prepartion.keyedDecodingContainer)
            _ = try encode(prepartion)
            registerEncodingContainer(&prepartion.keyedEncodingContainer!)
        } catch {}
    }

    private func registerDecodingContainer(_ container: inout KeyedDecodingContainer<PathCodingKey>) {
        decoderModifier = KeyedDecodingContainerModifier(refer: &container)
    }

    private func registerEncodingContainer(_ container: inout KeyedEncodingContainer<PathCodingKey>) {
        encoderModifier = KeyedEncodingContainerModifier(refer: &container)
    }

    func encodingContainerModifier<K>(for _: KeyedEncodingContainer<K>) -> KeyedEncodingContainerModifier? {
        encoderModifier
    }

    func decodingContainerModifier<K>(for _: KeyedDecodingContainer<K>) -> KeyedDecodingContainerModifier? {
        decoderModifier
    }
}
