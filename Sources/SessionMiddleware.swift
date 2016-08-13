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

        var err: Error? = nil
        var setCookie: Set<AttributedCookie>? = nil

        let onThread = {
            // Parse signedCookies
            req.storage["signedCookies"] = signedCookies(req.cookies, secret: self.session.secret)

            if self.shouldSetCookie(req) {
                do {
                    let cookie = try self.createCookieForSet()
                    setCookie = Set<AttributedCookie>([cookie])
                    req.session?.id = signedCookies(Set([Cookie(name: cookie.name, value: cookie.value)]), secret: self.session.secret)[self.session.keyName]
                } catch {
                    err = error
                }
            }
        }

        let onFinish = {
            if let e = err {
                result {
                    throw e
                }
                return
            }
            
            if let cookie = setCookie {
                next.respond(to: req) { getResponse in
                    result {
                        var response = try getResponse()
                        response.cookies = cookie // should merge
                        return response
                    }
                }
                return
            }

            guard let sessionId = (req.storage["signedCookies"] as? [String: String])?[self.session.keyName] , !sessionId.isEmpty else {
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

    private func shouldSetCookie(_ req: Request) -> Bool {
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

    private func createCookieForSet() throws -> AttributedCookie {
        let sessionId = try signSync(Session.generateId().hexadecimalString(), secret: session.secret)
        
        var maxAge: AttributedCookie.Expiration?
        if let ttl = session.ttl {
            maxAge = .maxAge(ttl)
        } else {
            maxAge = nil
        }
        
        return AttributedCookie(name: session.keyName, value: sessionId, expiration: maxAge , domain: session.domain, path: session.path, secure: session.secure, httpOnly: session.httpOnly)
    }
}
