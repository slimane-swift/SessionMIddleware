//
//  Cookie.swift
//  SessionMiddleware
//
//  Created by Yuki Takei on 4/18/16.
//
//

extension Collection where Self.Iterator.Element == Cookie {
    public subscript(key: String) -> String? {
        get {
            return self.filter { $0.name.lowercased() == key.lowercased() }.first?.value
        }
    }
}
