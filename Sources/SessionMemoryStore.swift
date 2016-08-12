//
//  SessionMemoryStore.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

private var sessionMap = [String: [String: String]]()

public struct SessionMemoryStore: SessionStoreType {

    public init(){}

    public func load(_ sessionId: String, completion: @escaping ((Void) throws -> [String: String]) -> Void) {
        guard let sesValues = sessionMap[sessionId] else {
            return completion { [:] }
        }
        completion { sesValues }
    }

    public func store(_ key: String, values: [String: String], expiration: Int?, completion: @escaping () -> Void) {
        sessionMap[key] = values
        completion()
    }

    public func destroy(_ sessionId: String) {
        sessionMap[sessionId] = nil
    }
}
