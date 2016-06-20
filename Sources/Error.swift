//
//  Error.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

internal enum Error: ErrorProtocol, CustomStringConvertible {
    case serializerFailure(String)
    case cookieParserFailure(String)
    case noSessionID
    
    var description: String {
        switch(self) {
        case .serializerFailure(let message):
            return message
        case .cookieParserFailure(let message):
            return message
        case .noSessionID:
            return "No session id"
        }
    }
}
