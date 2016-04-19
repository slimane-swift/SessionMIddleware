//
//  Middleware.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

@_exported import Middleware
@_exported import Time
@_exported import Crypto
@_exported import JSON
@_exported import Suv

func makeKey(key: String) -> String {
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

public struct SessionMiddleware: MiddlewareType {
    var session: Session

    public init(conf: SessionConfig){
        session = Session(conf: conf)
    }

    public func respond(req: Request, res: Response, next: MiddlewareChain) {
        var req = req
        var res = res
        req.storage[makeKey("session")] = session

        var err: ErrorProtocol? = nil

        let onThread = {
            // Parse signedCookies
            req.storage["signedCookies"] = signedCookies(req.cookies, secret: self.session.secret)

            if self.shouldSetCookie(req) {
                do {
                    let cookie = try self.initCookieForSet()
                    // Set-Cookie
                    res.cookies = Set([cookie])
                    // set sessionID
                    req.session?.id = signedCookies(Set([Cookie(name: cookie.name, value: cookie.value)]), secret: self.session.secret)[self.session.keyName]
                } catch {
                    err = error
                }
            }
        }

        let onFinish = {
            if let e = err {
                next(.Error(e))
                return
            }

            if !res.cookies.isEmpty {
                next(.Chain(req, res))
                return
            }

            guard let sessionId = (req.storage["signedCookies"] as? [String: String])?[self.session.keyName] else {
                next(.Chain(req, res))
                return
            }

            req.session?.id = sessionId

            req.session?.load() {
                req.session?.values = [:]

                if case .Error(let error) = $0 {
                    return next(.Error(error))
                }

                if case .Data(let sesValue) = $0 {
                    req.session?.values = sesValue
                }
                next(.Chain(req, res))
            }
        }

        Process.qwork(onThread: onThread, onFinish: onFinish)
    }


    private func shouldSetCookie(req: Request) -> Bool {
        guard let cookieValue = req.cookies[session.keyName] else {
            return true
        }

        do {
            let decoded = try String(percentEncoded: cookieValue)
            let dec = try signedCookie(decoded, secret: session.secret)
            let sesId = try decode(decoded)
            return dec != sesId
        } catch {
            return true
        }
    }

    private func initCookieForSet() throws -> AttributedCookie {
        let sessionId = try signSync(Session.generateId().hexadecimalString(), secret: session.secret)
        return AttributedCookie(name: session.keyName, value: sessionId, expires: session.expires?.rfc822, maxAge: session.maxAge, domain: session.domain, path: session.path, secure: session.secure, HTTPOnly: session.HTTPOnly)
    }
}
