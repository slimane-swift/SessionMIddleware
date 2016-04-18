//
//  Error.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

internal enum Error: ErrorProtocol, CustomStringConvertible {
    case SerializerFailure(String)
    case CookieParserFailure(String)
    case NoSessionID
    
    var description: String {
        switch(self) {
        case .SerializerFailure(let message):
            return message
        case .CookieParserFailure(let message):
            return message
        case .NoSessionID:
            return "No session id"
        }
    }
}
