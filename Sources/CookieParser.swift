//
//  CookieParser.swift
//  SessionMiddleware
//
//  Created by Yuki Takei on 4/18/16.
//
//

func signedCookies(_ cookies: Set<Cookie>, secret: String) -> [String: String] {
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

func decode(_ val: String) throws -> String {
    let str = val.substring(from: val.index(val.startIndex, offsetBy: 2))
    let searchCharacter: Character = "."
    guard let index = str.lowercased().characters.index(of: searchCharacter) else {
        throw SessionError.cookieParserFailure
    }
    return str.substring(to: index)
}

func signedCookie(_ val: String, secret: String) throws -> String? {
    let signedPrefix = val.substring(to: val.index(val.startIndex, offsetBy: 2))
    if signedPrefix != "s:" {
        return nil
    }

    return try unsignSync(val, secret: secret)
}

func signSync(_ val: String, secret: String) throws -> String {
    let encrypted = try Crypto.Hasher(.sha256).hashSync(secret)

    return "s:\(val).\(Base64.encode(Data(encrypted.bytes)))"
}

func unsignSync(_ val: String, secret: String) throws -> String {
    let str = try decode(val)

    let sha1 = Crypto.Hasher(.sha1)
    let mac = try signSync(str, secret: secret)

    let sha1mac = try sha1.hashSync(mac)
    let sha1val = try sha1.hashSync(val)

    if sha1mac.bytes != sha1val.bytes {
        throw SessionError.cookieParserFailure
    }

    return str
}
