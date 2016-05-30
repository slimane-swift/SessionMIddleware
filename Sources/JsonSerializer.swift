//
//  JsonSerializer.swift
//  MIddleware
//
//  Created by Yuki Takei on 4/16/16.
//
//

// Need to replace Foundation
import Foundation

public struct JsonSerializer: SerializerType {
    public init(){}

    public func serialize(_ src: [String: AnyObject]) throws -> String {
        let jsonData = try NSJSONSerialization.data(withJSONObject: src as! AnyObject, options: NSJSONWritingOptions(rawValue: 0))
        let jsonStr = String(NSString(data: jsonData, encoding: NSUTF8StringEncoding)!)

        return jsonStr
    }

    public func deserialize(_ src: String) throws -> [String: AnyObject] {
        let _data = src.data(using: NSUTF8StringEncoding)
        guard let data = _data else {
            throw Error.SerializerFailure("Could not parse the source")
        }

        let json = try NSJSONSerialization.jsonObject(with: data, options: NSJSONReadingOptions(rawValue: 0))
        return json as! [String: AnyObject]
    }
}
