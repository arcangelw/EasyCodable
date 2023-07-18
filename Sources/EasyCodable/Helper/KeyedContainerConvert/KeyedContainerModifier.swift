//
//  KeyedDecodingContainerModifier.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

// swiftlint:disable type_name line_length

/// KeyedDecodingContainer<PathCodingKey>内存布局缓存
class KeyedDecodingContainerModifier {
    let referPtrStruct: ContainerPtrStruct
    let concreteIsClass: Bool

    required init(refer: inout KeyedDecodingContainer<PathCodingKey>) {
        let referPointer = withUnsafePointer(to: &refer) { UnsafeRawPointer($0) }
        let box = referPointer.load(as: AnyObject.self)
        if let concrete = Mirror(reflecting: box).children.first?.value, Mirror(reflecting: concrete).displayStyle == .class {
            concreteIsClass = true
        } else {
            concreteIsClass = false
        }
        referPtrStruct = ContainerPtrStruct(containerPtr: referPointer, concreteIsClass: concreteIsClass)
    }

    /// 将`KeyedDecodingContainer<K>`转换为`KeyedDecodingContainer<PathCodingKey>`类型
    func convert<K>(target: inout KeyedDecodingContainer<K>, handler: (inout KeyedDecodingContainer<PathCodingKey>) throws -> Void) throws {
        let targetPointer = withUnsafePointer(to: &target) { UnsafeRawPointer($0) }
        let syncer = _KeyedContainerSyncer(refer: referPtrStruct, target: targetPointer, concreteIsClass: concreteIsClass)

        syncer.syncToRefer()
        var output = targetPointer.load(as: KeyedDecodingContainer<PathCodingKey>.self)
        try handler(&output)
        syncer.revert()
    }
}

/// KeyedEncodingContainer<PathCodingKey>内存布局缓存
class KeyedEncodingContainerModifier {
    let referPtrStruct: ContainerPtrStruct
    let concreteIsClass: Bool

    required init(refer: inout KeyedEncodingContainer<PathCodingKey>) {
        let referPointer = withUnsafePointer(to: &refer) { UnsafeRawPointer($0) }
        let box = referPointer.load(as: AnyObject.self)
        if let concrete = Mirror(reflecting: box).children.first?.value, Mirror(reflecting: concrete).displayStyle == .class {
            concreteIsClass = true
        } else {
            concreteIsClass = false
        }
        referPtrStruct = ContainerPtrStruct(containerPtr: referPointer, concreteIsClass: concreteIsClass)
    }

    /// 将`KeyedEncodingContainer<K>`转换为`KeyedEncodingContainer<PathCodingKey>`类型
    func convert<K>(target: inout KeyedEncodingContainer<K>, handler: (inout KeyedEncodingContainer<PathCodingKey>) throws -> Void) throws {
        let targetPointer = withUnsafePointer(to: &target) { UnsafeRawPointer($0) }
        let syncer = _KeyedContainerSyncer(refer: referPtrStruct, target: targetPointer, concreteIsClass: concreteIsClass)

        syncer.syncToRefer()
        var output = targetPointer.load(as: KeyedEncodingContainer<PathCodingKey>.self)
        try handler(&output)
        syncer.revert()
    }
}

enum KeyedContainerConvertError: Error {
    case unregistered
    case convertFailure
}

/// 类型转换
class _KeyedContainerSyncer {
    private let refer: ContainerPtrStruct
    private let target: ContainerPtrStruct
    private let concreteIsClass: Bool

    required init(refer: ContainerPtrStruct, target: UnsafeRawPointer, concreteIsClass: Bool) {
        self.refer = refer
        self.target = ContainerPtrStruct(containerPtr: target, concreteIsClass: concreteIsClass)
        self.concreteIsClass = concreteIsClass
    }

    func syncToRefer() {
        if concreteIsClass {
            // write convrete metadata
            target.boxPtr.advanced(by: MemoryLayout<Int>.size * 2).load(as: UnsafeMutableRawPointer.self).storeBytes(of: refer.concreteMedata, as: Int.self)
        }
        // write box metadata
        target.boxPtr.storeBytes(of: refer.boxMetadata, as: Int.self)
    }

    func revert() {
        if concreteIsClass {
            // revert convrete metadata
            target.boxPtr.advanced(by: MemoryLayout<Int>.size * 2).load(as: UnsafeMutableRawPointer.self).storeBytes(of: target.concreteMedata, as: Int.self)
        }
        // revert box metadata
        target.boxPtr.storeBytes(of: target.boxMetadata, as: Int.self)
    }
}

/// 内存结构
struct ContainerPtrStruct {
    let boxPtr: UnsafeMutableRawPointer
    let boxMetadata: Int
    var concretePtr: UnsafeMutableRawPointer!
    var concreteMedata: Int!

    init(containerPtr: UnsafeRawPointer, concreteIsClass: Bool) {
        boxPtr = containerPtr.load(as: UnsafeMutableRawPointer.self)
        boxMetadata = boxPtr.load(as: Int.self)

        if concreteIsClass {
            concretePtr = boxPtr.advanced(by: MemoryLayout<Int>.size * 2).load(as: UnsafeMutableRawPointer.self)
            concreteMedata = concretePtr?.load(as: Int.self)
        }
    }
}

// swiftlint:enable type_name line_length
