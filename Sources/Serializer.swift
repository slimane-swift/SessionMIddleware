//
//  Serializer.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public protocol SerializerType {
    func serialize(_ src: [String: String]) throws -> String
    func deserialize(_ src: String) throws -> [String: String]
}
