//
//  TransformOf.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

/// 通用类型转换容器
open class TransformOf<Object, JSON>: TransformType {
    open var fromJSON: (JSON?) -> Object
    open var toJSON: (Object) -> JSON?
    open var hash: Int

    public init(
        fromJSON: @escaping ((JSON?) -> Object),
        toJSON: @escaping ((Object) -> JSON?),
        file: String = #file,
        line: Int = #line,
        column: Int = #column
    ) {
        self.fromJSON = fromJSON
        self.toJSON = toJSON

        var hasher = Hasher()
        hasher.combine(String(describing: Object.self))
        hasher.combine(file)
        hasher.combine(line)
        hasher.combine(column)
        hash = hasher.finalize()
    }

    open func transformFromJSON(_ json: JSON?) -> Object {
        fromJSON(json)
    }

    open func transformToJSON(_ object: Object) -> JSON? {
        toJSON(object)
    }

    open func hashValue() -> Int {
        return hash
    }
}
