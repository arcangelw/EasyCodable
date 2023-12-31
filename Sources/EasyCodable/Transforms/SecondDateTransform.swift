//
//  SecondDateTransform.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

// MARK: - 提供标准时间转换

/// 秒级时间戳转换
public struct SecondDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Any

    public init() {}

    public func transformFromJSON(_ json: Any?) -> Date {
        if let time = getTimeInterval(json) {
            return Date(timeIntervalSince1970: TimeInterval(time))
        }
        return Date(timeIntervalSince1970: 0)
    }

    public func transformToJSON(_ object: Date) -> Any? {
        TimeInterval(object.timeIntervalSince1970)
    }

    public func hashValue() -> Int {
        String(describing: Self.self).hashValue
    }
}

/// 毫秒级时间戳转换
public struct MillisecondDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Any

    public init() {}

    public func transformFromJSON(_ json: Any?) -> Date {
        if let time = getTimeInterval(json) {
            return Date(timeIntervalSince1970: TimeInterval(time / 1000))
        }
        return Date(timeIntervalSince1970: 0)
    }

    public func transformToJSON(_ object: Date) -> Any? {
        Double(object.timeIntervalSince1970 * 1000)
    }

    public func hashValue() -> Int {
        String(describing: Self.self).hashValue
    }
}

/// Date时间转换
open class DateFormatterTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String

    public let dateFormatter: DateFormatter

    public func transformFromJSON(_ json: String?) -> Date {
        if let dateString = json, let date = dateFormatter.date(from: dateString) {
            return date
        }
        return Date(timeIntervalSince1970: 0)
    }

    public func transformToJSON(_ object: Date) -> String? {
        dateFormatter.string(from: object)
    }

    public func hashValue() -> Int {
        dateFormatter.hashValue
    }

    public init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
}

/// ISO8601标准时间转换
public final class ISO8601DateTransform: DateFormatterTransform {
    public init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        super.init(dateFormatter: formatter)
    }
}

/// 时间戳类型转换
private func getTimeInterval(_ value: Any?) -> TimeInterval? {
    if let value = value as? TimeInterval {
        return value
    }
    if let value = value as? Int {
        return TimeInterval(value)
    }
    if let value = value as? String, let value2 = TimeInterval(value) {
        return value2
    }
    return nil
}
