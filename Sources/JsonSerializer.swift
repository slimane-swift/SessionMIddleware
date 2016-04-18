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
        let jsonData = try NSJSONSerialization.data(withJSONObject: src, options: NSJSONWritingOptions(rawValue: 0))
        
        let jsonStr = String(NSString(data: jsonData, encoding: NSUTF8StringEncoding)!)
        
        return jsonStr
    }
    
    public func deserialize(src: String) throws -> [String: AnyObject] {
        guard let data = src.data(usingEncoding: NSUTF8StringEncoding) else {
            throw Error.SerializerFailure("Could not parse the source")
        }
        
        let json = try NSJSONSerialization.jsonObject(with: data, options: NSJSONReadingOptions(rawValue: 0)) as! [String: AnyObject]
        return json
    }
}
