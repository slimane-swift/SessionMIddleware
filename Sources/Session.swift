//
//  Session.swift
//  SessionMiddleware
//
//  Created by Yuki Takei on 4/15/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public struct SessionConfig {
    public let store: SessionStoreType

    public let keyName: String

    public let secret: String

    public let expires: Int?

    public let HTTPOnly: Bool

    public let secure: Bool

    public let maxAge: Int?

    public let domain: String?

    public let path: String?

    public init(keyName: String = "slimane_sesid", secret: String, expires: Int? = nil, HTTPOnly: Bool = false, maxAge: Int? = nil, domain: String? = nil, path: String? = nil, secure: Bool = false, store: SessionStoreType = SessionMemoryStore()){
        self.keyName = keyName
        self.secret = secret
        self.store = store
        self.expires = expires
        self.HTTPOnly = HTTPOnly
        self.secure = secure
        self.maxAge = maxAge
        self.domain = domain
        self.path = path
    }
}

public struct Session {

    private var conf: SessionConfig

    public internal(set) var id: String? = nil

    var values = [String: String]() {
        didSet {
            if let id = self.id {
                // Need to emit string error
                self.conf.store.store(id, values: values, expires: ttl) { _ in }
            }
        }
    }

    init(conf: SessionConfig){
        self.conf = conf
    }

    public var keyName: String {
        return self.conf.keyName
    }

    public var secret: String {
        return self.conf.secret
    }

    public var HTTPOnly: Bool {
        return self.conf.HTTPOnly
    }

    public var secure: Bool {
        return self.conf.secure
    }

    public var maxAge: Int? {
        return self.conf.maxAge
    }

    public var domain: String? {
        return self.conf.domain
    }

    public var path: String? {
        return self.conf.path
    }

    public var expires: Time? {
        if let ttl = self.ttl {
            return Time(tz: .Local).addSec(ttl)
        }
        return nil
    }

    public var ttl: Int? {
        return self.conf.expires
    }

    public var hashValue: Int {
        return self.conf.keyName.hashValue
    }

    public func load(_ completion: (SessionResult<[String: String]>) -> Void){
        if let id = self.id {
            self.conf.store.load(id, completion: completion)
        } else {
            completion(.error(Error.noSessionID))
        }
    }

    public func destroy(){
        if let id = self.id {
            self.conf.store.destroy(id)
        }
    }

    public static func generateId(_ size: UInt = 12) throws -> Data {
        return try Crypto.randomBytesSync(size)
    }
}

extension Session: Sequence {
    
    #if swift(>=3.0)
    public func makeIterator() -> DictionaryIterator<String, String> {
        return values.makeIterator()
    }
    #else
    public func generate() -> DictionaryGenerator<String, String> {
        return values.generate()
    }
    #endif
    
    public var count: Int {
        return values.count
    }
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
    
    public subscript(key: String) -> String? {
        get {
            guard let value = self.values[key] else {
                return nil
            }
            
            return value
        }
        
        set {
            self.values[key] = newValue
        }
    }
}