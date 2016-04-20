//
//  SessionMemoryStore.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

private var sessionMap = [String: [String: AnyObject]]()

public struct SessionMemoryStore: SessionStoreType {

    public func load(sessionId: String, completion: (SessionResult<[String: AnyObject]>) -> Void) {
        guard let sesValues = sessionMap[sessionId] else {
            return completion(.Data([:]))
        }
        completion(.Data(sesValues))
    }

    public func store(key: String, values: [String: AnyObject], expires: Int?, completion: () -> Void) {
        sessionMap[key] = values
        completion()
    }

    public func destroy(sessionId: String) {
        sessionMap[sessionId] = nil
    }
}
