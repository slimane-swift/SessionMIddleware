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

    public init(conf: SessionConfig){
        session = Session(conf: conf)
    }

    public func respond(to request: Request, chainingTo next: AsyncResponder, result: ((Void) throws -> Response) -> Void) {
        var req = request
        req.storage[makeKey("session")] = session

        var err: ErrorProtocol? = nil
        var setCookie: S4.Cookies? = nil

        let onThread = {
            // Parse signedCookies
            if let cookieString = req.headers["cookie"], cookies = HTTP.Cookie.parse(string: cookieString) {
                req.storage["signedCookies"] = signedCookies(cookies, secret: self.session.secret)
            }

            if self.shouldSetCookie(req) {
                do {
                    let cookie = try self.initCookieForSet()
                    setCookie = S4.Cookies(cookies: [cookie])
                    req.session?.id = signedCookies(Set([HTTP.Cookie(name: cookie.name, value: cookie.value)]), secret: self.session.secret)[self.session.keyName]
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

            guard let sessionId = (req.storage["signedCookies"] as? [String: String])?[self.session.keyName] else {
                next.respond(to: req, result: result)
                return
            }

            req.session?.id = sessionId

            req.session?.load() {
                req.session?.values = [:]

                if case .error(let error) = $0 {
                    result {
                        throw error
                    }
                }
                else if case .data(let sesValue) = $0 {
                    req.session?.values = sesValue
                }
                next.respond(to: req, result: result)
            }
        }

        Process.qwork(onThread: onThread, onFinish: onFinish)
    }


    private func shouldSetCookie(_ req: Request) -> Bool {
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

    private func initCookieForSet() throws -> S4.Cookie {
        let sessionId = try signSync(Session.generateId().hexadecimalString(), secret: session.secret)
        return S4.Cookie(name: session.keyName, value: sessionId, expires: session.expires?.rfc822, maxAge: session.maxAge, domain: session.domain, path: session.path, secure: session.secure, HTTPOnly: session.HTTPOnly)
    }
}
