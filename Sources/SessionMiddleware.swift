//
//  Middleware.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

@_exported import HTTP
@_exported import Time
@_exported import Crypto
@_exported import Suv

func makeKey(_ key: String) -> String {
    return "Slimane.SessionMiddleware.\(key)"
}

extension Request {
    public var session: Session? {
        get {
            guard let session = storage[makeKey("session")] else {
                return nil
            }

            return session as? Session
        }

        set {
            storage[makeKey("session")] = newValue
        }
    }
}

public struct SessionMiddleware: AsyncMiddleware {
    var session: Session

    public init(config: SessionConfig){
        session = Session(config: config)
    }

    public func respond(to request: Request, chainingTo next: AsyncResponder, result: @escaping ((Void) throws -> Response) -> Void) {
        var req = request
        req.storage[makeKey("session")] = session

        let onThread: (QueueWorkContext) -> Void = { ctx in
            // Parse signedCookies
            ctx.storage["signedCookies"] = signedCookies(req.cookies, secret: self.session.secret)
            if shouldSetCookie(req, self.session) {
                do {
                    let cookie = try createCookieForSet(self.session)
                    let setCookie = Set<AttributedCookie>([cookie])
                    ctx.storage["session.setCookie"] = setCookie
                    ctx.storage["session.id"] = signedCookies(Set([Cookie(name: cookie.name, value: cookie.value)]), secret: self.session.secret)[self.session.keyName]
                } catch {
                    ctx.storage["session.error"] = error
                }
            }
        }

        let onFinish: (QueueWorkContext) -> Void = { ctx in
            if let error = ctx.storage["session.error"] as? Error {
                result { throw error }
                return
            }
            
            if let cookie = ctx.storage["session.setCookie"] as? Set<AttributedCookie> {
                req.session?.id = ctx.storage["session.id"] as? String
                next.respond(to: req) { getResponse in
                    result {
                        var response = try getResponse()
                        response.cookies = cookie
                        return response
                    }
                }
                return
            }

            guard let sessionId = (ctx.storage["signedCookies"] as? [String: String])?[self.session.keyName] , !sessionId.isEmpty else {
                next.respond(to: req, result: result)
                return
            }

            req.session?.id = sessionId

            req.session?.load() { getData in
                req.session?.values = [:]
                
                do {
                    let data = try getData()
                    req.session?.values = data
                } catch {
                    return result {
                        throw error
                    }
                }
                
                next.respond(to: req, result: result)
            }
        }
        
        Process.qwork(onThread: onThread, onFinish: onFinish)
    }
}


private func shouldSetCookie(_ req: Request, _ session: Session) -> Bool {
    guard let cookieValue = req.cookies.filter({ $0.name.trim() == session.keyName }).map({ $0.value }).first else {
        return true
    }
    
    do {
        let dec = try signedCookie(cookieValue, secret: session.secret)
        let sesId = try decode(cookieValue)
        
        return dec != sesId
    } catch {
        return true
    }
}

private func createCookieForSet(_ session: Session) throws -> AttributedCookie {
    let sessionId = try signSync(Session.generateId().hexadecimalString(), secret: session.secret)
    
    var maxAge: AttributedCookie.Expiration?
    if let ttl = session.ttl {
        maxAge = .maxAge(ttl)
    } else {
        maxAge = nil
    }
    
    return AttributedCookie(name: session.keyName, value: sessionId, expiration: maxAge , domain: session.domain, path: session.path, secure: session.secure, httpOnly: session.httpOnly)
}
