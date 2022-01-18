//
//  DataConvertible.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol NumberConvertible {
    var asNumber: Number { get }
}

func * (lhs: NumberConvertible, rhs: NumberConvertible) -> Number {
    return lhs.asNumber * rhs.asNumber
}
func * (lhs: NumberConvertible, rhs: Number) -> Number {
    return lhs.asNumber * rhs
}
func * (lhs: Number, rhs: NumberConvertible) -> Number {
    return lhs * rhs.asNumber
}
func + (lhs: NumberConvertible, rhs: NumberConvertible) -> Number {
    return lhs.asNumber + rhs.asNumber
}
func + (lhs: NumberConvertible, rhs: Number) -> Number {
    return lhs.asNumber + rhs
}
func + (lhs: Number, rhs: NumberConvertible) -> Number {
    return lhs + rhs.asNumber
}

public protocol DataConvertible: NumberConvertible {
    var asData: Data { get }
    var asHex: String { get }
//    init(data: Data)
}

extension Number {
    init(_ data: DataConvertible) {
        self.init(data: data.asData)
    }
}

extension Data {
    var byteCount: Int {
        return count
    }
}
public extension Data {
    init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
    
    var bytes: Array<UInt8> {
        Array(self)
    }
    
    func toHexString() -> String {
        self.bytes.toHexString()
    }
}
extension Array {
    init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }
    
    var slice: ArraySlice<Element> {
        self[self.startIndex ..< self.endIndex]
    }
}

extension Array where Element == UInt8 {
    public init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    public func toHexString() -> String {
        `lazy`.reduce(into: "") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            $0 += s
        }
    }
}


//extension Array where Element == Byte {
//    func toHexString() -> String {
//        fatalError()
//    }
//}

extension String: DataConvertible {
    public var asData: Data {
//        fatalError()
        data(using: .utf8)!
    }
    
    
}

extension NumberConvertible where Self: DataConvertible {
    public var asNumber: Number {
        return asData.toNumber()
    }
}

public extension DataConvertible {

    var byteCount: Int { asData.byteCount }
    
    var bytes: [Byte] { asData.bytes }

    var asHex: String { asData.toHexString() }
}

func + (data: DataConvertible, byte: Byte) -> Data {
    return data.asData + Data([byte])
}

func + (lhs: Data, rhs: DataConvertible) -> Data {
    return Data(lhs.bytes + rhs.asData.bytes)
}

func + (lhs: DataConvertible, rhs: DataConvertible) -> Data {
    var bytes: [Byte] = lhs.bytes
    bytes.append(contentsOf: rhs.bytes)
    return Data(bytes)
}

func + (lhs: DataConvertible, rhs: DataConvertible?) -> Data {
    guard let rhs = rhs else { return lhs.asData }
    return lhs + rhs
}

func + (data: Data, byte: Byte) -> Data {
    return data + Data([byte])
}

func + (lhs: Data, rhs: Data?) -> Data {
    guard let rhs = rhs else { return lhs }
    return lhs + rhs
}

extension Data: ExpressibleByArrayLiteral {
    public init(arrayLiteral bytes: Byte...) {
        self.init(bytes)
    }
}

extension Array: NumberConvertible where Element == Byte {
    public var asNumber: Number {
        return asData.toNumber()
    }
}

extension Array: DataConvertible where Element == Byte {

    public var asData: Data { return Data(self) }
    public init(data: Data) {
        self.init(data.bytes)
    }
}

//extension Array: DataConvertible where Element == Byte {
//    public var asData: Data { return Data(self) }
//    public init(data: Data) {
//        self.init(data.bytes)
//    }
//}

extension Data: DataConvertible {
    public var asData: Data { return self }
    public init(data: Data) {
        self = data
    }
}

extension Byte: DataConvertible {
    public var asData: Data { return Data([self]) }
    public init(data: Data) {
        self = data.bytes.first ?? 0x00
    }
}

public extension BinaryInteger {
    var asData: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}

extension Int8: DataConvertible {}

extension UInt16: DataConvertible {}
extension Int16: DataConvertible {}

extension UInt32: DataConvertible {}
extension Int32: DataConvertible {}

extension UInt64: DataConvertible {}
extension Int64: DataConvertible {}
