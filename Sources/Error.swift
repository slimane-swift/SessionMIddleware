//
//  Error.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

internal enum SessionError: Error {
    case serializerFailure
    case cookieParserFailure
    case noSessionID
}
