//
//  EasyBridgeType.swift
//
//
//  Created by 吴哲 on 2023/7/17.
//

import Foundation

// swiftlint:disable identifier_name line_length cyclomatic_complexity

// MARK: - 基础类型转换

protocol _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> Self?
}

// MARK: - Suppport Integer Type

protocol _EasyIntegerPropertyProtocol: FixedWidthInteger, _EasyBuiltInBridgeType {
    init?(_ text: String, radix: Int)
    init(truncating number: NSNumber)
}

extension _EasyIntegerPropertyProtocol {
    static func _transform(from object: Any) -> Self? {
        switch object {
        case let stringValue as String:
            return .init(stringValue, radix: 10)
        case let numberValue as NSNumber:
            return .init(truncating: numberValue)
        default: return nil
        }
    }
}

extension Int: _EasyIntegerPropertyProtocol {}
extension UInt: _EasyIntegerPropertyProtocol {}
extension Int8: _EasyIntegerPropertyProtocol {}
extension Int16: _EasyIntegerPropertyProtocol {}
extension Int32: _EasyIntegerPropertyProtocol {}
extension Int64: _EasyIntegerPropertyProtocol {}
extension UInt8: _EasyIntegerPropertyProtocol {}
extension UInt16: _EasyIntegerPropertyProtocol {}
extension UInt32: _EasyIntegerPropertyProtocol {}
extension UInt64: _EasyIntegerPropertyProtocol {}

extension Bool: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> Bool? {
        switch object {
        case let stringValue as String:
            enum LowerCase {
                static let trues = ["true", "yes", "1", "y", "t"]
                static let falses = ["false", "no", "0", "n", "f"]
            }
            let lowerCase = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if LowerCase.trues.contains(lowerCase) {
                return true
            }
            if LowerCase.falses.contains(lowerCase) {
                return false
            }
            return nil
        case let numberValue as NSNumber:
            return numberValue.boolValue
        default:
            return nil
        }
    }
}

// MARK: - Support Float Type

protocol _EasyFloatPropertyProtocol: _EasyBuiltInBridgeType, LosslessStringConvertible {
    init(truncating number: NSNumber)
}

extension _EasyFloatPropertyProtocol {
    static func _transform(from object: Any) -> Self? {
        switch object {
        case let stringValue as String:
            return .init(stringValue)
        case let numberValue as NSNumber:
            return .init(truncating: numberValue)
        default:
            return nil
        }
    }
}

// FIXME: - Float 转换过程中精度丢失
extension Float: _EasyFloatPropertyProtocol {}
extension Double: _EasyFloatPropertyProtocol {}
extension CGFloat: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> CGFloat? {
        switch object {
        case let stringValue as NSString:
            return .init(stringValue.doubleValue)
        case let numberValue as NSNumber:
            return .init(truncating: numberValue)
        default:
            return nil
        }
    }
}

extension NSNumber {
    var isBool: Bool {
        enum Once {
            static let trueNumber = NSNumber(value: true)
            static let falseNumber = NSNumber(value: false)
            static let trueObjCType = String(cString: trueNumber.objCType)
            static let falseObjCType = String(cString: falseNumber.objCType)
        }

        let objCType = String(cString: self.objCType)
        if (compare(Once.trueNumber) == .orderedSame && objCType == Once.trueObjCType) || (compare(Once.falseNumber) == .orderedSame && objCType == Once.falseObjCType) {
            return true
        } else {
            return false
        }
    }
}

extension String: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> String? {
        switch object {
        case let stringValue as String:
            return stringValue
        case let numberValue as NSNumber:
            // Boolean Type Inside
            if numberValue.isBool {
                if numberValue.boolValue {
                    return "true"
                } else {
                    return "false"
                }
            }
            return numberValue.stringValue
        case _ as NSNull:
            return nil
        default:
            return "\(object)"
        }
    }
}

extension NSString: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> Self? {
        if let stringValue = String._transform(from: object) {
            return Self(string: stringValue)
        }
        return nil
    }
}

extension NSNumber: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> Self? {
        switch object {
        case let numberValue as Self:
            return numberValue
        case let numberValue as NSNumber where self == NSDecimalNumber.self:
            return NSDecimalNumber(decimal: numberValue.decimalValue) as? Self
        case let stringValue as String:
            enum LowerCase {
                static let trues = ["true", "yes", "y", "t"]
                static let falses = ["false", "no", "n", "f"]
                static let nils = ["nil", "null", "<null>"]
            }
            let lowercase = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !lowercase.isEmpty else { return nil }
            if LowerCase.trues.contains(lowercase) {
                return .init(booleanLiteral: true)
            } else if LowerCase.falses.contains(lowercase) {
                return .init(booleanLiteral: false)
            } else if !LowerCase.nils.contains(lowercase) {
                // hex number
//                let sign: Int64
//                if lowercase.hasPrefix("0x") {
//                    sign = 1
//                } else if lowercase.hasPrefix("-0x") {
//                    sign = -1
//                } else {
//                    sign = 0
//                }
                if lowercase.hasPrefix("0x") || lowercase.hasPrefix("-0x") {
                    let scanner = Scanner(string: lowercase)
                    var hexValue: Double = 0
                    if scanner.scanHexDouble(&hexValue) {
                        return .init(value: hexValue)
                    }
                    return nil
                }

                // normal number
                let decimal = NSDecimalNumber(string: stringValue)
                guard decimal != .notANumber else { return nil }
                if let numberValue = decimal as? Self {
                    return numberValue
                } else {
                    return .init(value: decimal.doubleValue)
                }
            }
            return nil
        default:
            return nil
        }
    }
}

extension NSArray: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> Self? {
        return object as? Self
    }
}

extension NSDictionary: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> Self? {
        return object as? Self
    }
}

extension Optional: _EasyBuiltInBridgeType {
    static func _transform(from object: Any) -> Optional? {
        if let value = (Wrapped.self as? _EasyBuiltInBridgeType.Type)?._transform(from: object) as? Wrapped {
            return Optional(value)
        } else if let value = object as? Wrapped {
            return Optional(value)
        }
        return nil
    }
}

// swiftlint:enable identifier_name line_length cyclomatic_complexity
