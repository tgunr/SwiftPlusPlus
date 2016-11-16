//
//  NativeTypesDecoder.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 2/27/16.
//  Copyright © 2016 Drewag LLC. All rights reserved.
//

import Foundation

public final class NativeTypesDecoder: DecoderType {
    let raw: AnyObject

    public class func decodableTypeFromObject<E: EncodableType>(_ raw: AnyObject) -> E? {
        guard !(raw is NSNull) else {
            return nil
        }

        let decoder = NativeTypesDecoder(raw: raw)
        return E(decoder: decoder)
    }

    fileprivate init(raw: AnyObject) {
        self.raw = raw
    }

    public func decode<Value: RawEncodableType>(_ key: CoderKey<Value>.Type) -> Value {
        let object = self.object(forKeyPath: key.path)
        return object as! Value
    }

    public func decode<Value: RawEncodableType>(_ key: OptionalCoderKey<Value>.Type) -> Value? {
        guard let object = self.object(forKeyPath: key.path) else {
           return nil
        }
        return object as? Value
    }


    public func decode<Value: EncodableType>(_ key: NestedCoderKey<Value>.Type) -> Value {
        let object = self.object(forKeyPath: key.path)!
        return NativeTypesDecoder.decodableTypeFromObject(object)!
    }

    public func decode<Value: EncodableType>(_ key: OptionalNestedCoderKey<Value>.Type) -> Value? {
        guard let object = self.object(forKeyPath: key.path) else {
            return nil
        }
        return NativeTypesDecoder.decodableTypeFromObject(object)
    }

    public func decodeArray<Value: RawEncodableType>(_ key: CoderKey<Value>.Type) -> [Value] {
        guard let array = self.object(forKeyPath: key.path) as? [AnyObject] else {
            fatalError("Unexpected type")
        }
        var output: [Value] = []
        for raw in array {
            output.append(raw as! Value)
        }
        return output
    }

    public func decodeArray<Value: EncodableType>(_ key: NestedCoderKey<Value>.Type) -> [Value] {
        let object = self.object(forKeyPath: key.path)
        guard let array = object as? [AnyObject] else {
            if object is NSNull || object == nil {
                return []
            }
            else {
                fatalError("Unexpected type")
            }
        }
        var output: [Value] = []
        for raw in array {
            let object: Value = NativeTypesDecoder.decodableTypeFromObject(raw)!
            output.append(object)
        }
        return output
    }
}

private extension NativeTypesDecoder {
    func object(forKeyPath path: [String]) -> AnyObject? {
        switch self.raw {
        case var dict as [String:AnyObject]:
            for (i, key) in path.enumerated() {
                guard i < path.count - 1 else {
                    return dict[key]
                }
                guard let newDict = dict[key] as? [String:AnyObject] else {
                    return nil
                }
                dict = newDict
            }
            return nil
        default:
            fatalError("Unexpected type")
        }
    }
}
