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

    public let expiration: Int?

    public let httpOnly: Bool

    public let secure: Bool

    public let maxAge: Int?

    public let domain: String?

    public let path: String?

    public init(keyName: String = "slimane_sesid", secret: String, expiration: Int? = nil, httpOnly: Bool = false, maxAge: Int? = nil, domain: String? = nil, path: String? = "/", secure: Bool = false, store: SessionStoreType = SessionMemoryStore()){
        self.keyName = keyName
        self.secret = secret
        self.store = store
        self.expiration = expiration
        self.httpOnly = httpOnly
        self.secure = secure
        self.maxAge = maxAge
        self.domain = domain
        self.path = path
    }
}

public struct Session {

    private var config: SessionConfig

    public internal(set) var id: String? = nil

    var values = [String: String]() {
        didSet {
            if let id = self.id {
                // Need to emit string error
                self.config.store.store(id, values: values, expiration: ttl) { _ in }
            }
        }
    }

    init(config: SessionConfig){
        self.config = config
    }

    public var keyName: String {
        return self.config.keyName
    }

    public var secret: String {
        return self.config.secret
    }

    public var httpOnly: Bool {
        return self.config.httpOnly
    }

    public var secure: Bool {
        return self.config.secure
    }

    public var maxAge: Int? {
        return self.config.maxAge
    }

    public var domain: String? {
        return self.config.domain
    }

    public var path: String? {
        return self.config.path
    }

    public var expiration: Time? {
        if let ttl = self.ttl {
            return Time(tz: .Local).addSec(ttl)
        }
        return nil
    }

    public var ttl: Int? {
        return self.config.expiration
    }

    public var hashValue: Int {
        return self.config.keyName.hashValue
    }

    public func load(_ completion: @escaping ((Void) throws -> [String: String]) -> Void){
        if let id = self.id {
            self.config.store.load(id, completion: completion)
        } else {
            completion {
                throw SessionError.noSessionID
            }
        }
    }

    public func destroy(){
        if let id = self.id {
            self.config.store.destroy(id)
        }
    }

    public static func generateId(_ size: UInt = 12) throws -> Data {
        return try Crypto.randomBytesSync(size)
    }
}

extension Session: Sequence {
    
    public func makeIterator() -> DictionaryIterator<String, String> {
        return values.makeIterator()
    }
    
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
