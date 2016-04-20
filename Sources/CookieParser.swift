//
//  CookieParser.swift
//  SessionMiddleware
//
//  Created by Yuki Takei on 4/18/16.
//
//
#if os(Linux)
extension String {
    func substring(from from: Index) -> String {
        return self.substringFromIndex(from)
    }

    func substring(to to: Index) -> String {
        return self.substringToIndex(to)
    }
}
#endif

func signedCookies(cookies: Set<Cookie>, secret: String) -> [String: String] {
    var signedCookies = [String: String]()

    cookies.forEach {
        do {
            signedCookies[$0.name] = try signedCookie($0.value, secret: secret)
        } catch {
            // noop
        }
    }

    return signedCookies
}

func decode(val: String) throws -> String {
    let str = val.substring(from: val.startIndex.advanced(by: 2))
    let searchCharacter: Character = "."
    guard let index = str.lowercased().characters.index(of: searchCharacter) else {
        throw Error.CookieParserFailure("Invalid cookie value")
    }
    return str.substring(to: index)
}

func signedCookie(val: String, secret: String) throws -> String? {
    let signedPrefix = val.substring(to: val.startIndex.advanced(by: 2))
    if signedPrefix != "s:" {
        return nil
    }

    return try unsignSync(val, secret: secret)
}

func signSync(val: String, secret: String) throws -> String {
    let encrypted = try Crypto.Hasher(.SHA256).hashSync(secret)

    let buf = Buffer(encrypted.bytes)

    return "s:\(val).\(buf.toString(.Base64)!)"
}

func unsignSync(val: String, secret: String) throws -> String {
    let str = try decode(val)

    let sha1 = Crypto.Hasher(.SHA1)
    let mac = try signSync(str, secret: secret)

    let sha1mac = try sha1.hashSync(mac)
    let sha1val = try sha1.hashSync(val)

    if sha1mac.bytes != sha1val.bytes {
        throw Error.CookieParserFailure("Invalid session value")
    }

    return str
}
