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

    public func serialize(src: [String: AnyObject]) throws -> String {
#if os(Linux)
        let jsonData = try NSJSONSerialization.dataWithJSONObject(src as! AnyObject, options: NSJSONWritingOptions(rawValue: 0))
#else
        let jsonData = try NSJSONSerialization.data(withJSONObject: src, options: NSJSONWritingOptions(rawValue: 0))
#endif

        let jsonStr = String(NSString(data: jsonData, encoding: NSUTF8StringEncoding)!)

        return jsonStr
    }

    public func deserialize(src: String) throws -> [String: AnyObject] {
#if os(Linux)
        let _data = src.dataUsingEncoding(NSUTF8StringEncoding)
#else
        let _data = src.data(usingEncoding: NSUTF8StringEncoding)
#endif

        guard let data = _data else {
            throw Error.SerializerFailure("Could not parse the source")
        }

#if os(Linux)
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
#else
        let json = try NSJSONSerialization.jsonObject(with: data, options: NSJSONReadingOptions(rawValue: 0))
#endif
        return json as! [String: AnyObject]
    }
}
