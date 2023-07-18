//
//  TransformType.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

/// 数据转换
public protocol TransformType {
    /// 目标对象
    associatedtype Object
    /// 原始对象
    associatedtype JSON

    func transformFromJSON(_ json: JSON?) -> Object
    func transformToJSON(_ object: Object) -> JSON?
    func hashValue() -> Int
}
