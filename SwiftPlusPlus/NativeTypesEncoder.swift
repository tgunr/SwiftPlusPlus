//
//  NativeTypesEncoder.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 2/27/16.
//  Copyright © 2016 Drewag LLC. All rights reserved.
//

import Foundation

public final class NativeTypesEncoder: EncoderType {
    fileprivate var raw: AnyObject?

    public class func objectFromEncodable(encodable: EncodableType) -> AnyObject {
        let encoder = NativeTypesEncoder()
        encodable.encode(encoder)
        if encoder.raw == nil {
            return [:] as AnyObject
        } else {
            return encoder.raw!
        }
    }

    public func encode<Value: RawEncodableType>(_ data: Value, forKey key: CoderKey<Value>.Type) {
        self.addValue(data.asObject, keyPath: key.path)
    }

    public func encode<Value: RawEncodableType>(_ data: Value?, forKey key: OptionalCoderKey<Value>.Type) {
        self.addValue(data?.asObject, keyPath: key.path)
    }

    public func encode<Value: EncodableType>(_ data: Value, forKey key: NestedCoderKey<Value>.Type) {
        self.addValue(NativeTypesEncoder.objectFromEncodable(encodable: data), keyPath: key.path)
    }

    public func encode<Value: EncodableType>(_ data: Value?, forKey key: OptionalNestedCoderKey<Value>.Type) {
        if let data = data {
            self.addValue(NativeTypesEncoder.objectFromEncodable(encodable: data), keyPath: key.path)
        }
        else {
            self.addValue(nil, keyPath: key.path)
        }
    }

    public func encode<Value: RawEncodableType>(_ data: [Value], forKey key: CoderKey<Value>.Type) {
        var array = [AnyObject]()
        for value in data {
            array.append(value.asObject)
        }
        self.addValue(array as AnyObject?, keyPath: key.path)
    }

    public func encode<Value: EncodableType>(_ data: [Value], forKey key: NestedCoderKey<Value>.Type) {
        var array = [AnyObject]()
        for value in data {
            let object = NativeTypesEncoder.objectFromEncodable(encodable: value)
            array.append(object)
        }
        self.addValue(array as AnyObject?, keyPath: key.path)
    }
}

private extension NativeTypesEncoder {
    func addValue(_ value: AnyObject?, keyPath path: [String]) {
        let rawDict: [String:AnyObject]
        switch self.raw {
        case let dict as [String:AnyObject]:
            rawDict = dict
        case nil:
            rawDict = [String:AnyObject]()
        default:
            fatalError("Unexpected type")
        }

        self.raw = self.valueDict(forRemainingPath: path, withValue: value, andOriginalDict: rawDict) as AnyObject?
    }

    func valueDict(forRemainingPath path: [String], withValue value: AnyObject?, andOriginalDict originalDict: [String:AnyObject]) -> [String:AnyObject] {
        var originalDict = originalDict
        var path = path
        let object: AnyObject?
        guard path.count > 1 else {
            object = value
            originalDict[path.first!] = object
            return originalDict
        }

        let key = path.removeFirst()
        if let nextDict = originalDict[key] as? [String:AnyObject] {
            object = self.valueDict(forRemainingPath: path, withValue: value, andOriginalDict: nextDict) as AnyObject?
        }
        else {
            object = self.valueDict(forRemainingPath: path, withValue: value, andOriginalDict: [String:AnyObject]()) as AnyObject?
        }

        originalDict[key] = object
        return originalDict
    }
}
