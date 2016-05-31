//
//  SessionStoreType.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public enum SessionResult<T> {
    case Data(T)
    case Error(ErrorProtocol)
}

public protocol SessionStoreType {
    func destroy(_ sessionId: String)
    func load(_ sessionId: String, completion: (SessionResult<[String: String]>) -> Void)
    func store(_ sessionId: String, values: [String: String], expires: Int?, completion: () -> Void)
}
