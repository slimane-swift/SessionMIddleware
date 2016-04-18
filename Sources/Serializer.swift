//
//  Serializer.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public protocol SerializerType {
    func serialize(src: [String: AnyObject]) throws -> String
    func deserialize(src: String) throws -> [String: AnyObject]
}

