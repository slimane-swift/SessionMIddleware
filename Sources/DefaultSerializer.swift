//
//  DefaultSerializer.swift
//  MIddleware
//
//  Created by Yuki Takei on 4/16/16.
//
//

// Need to replace Foundation
import Foundation

extension String {
    func splitBy(separator: Character, allowEmptySlices: Bool = false, maxSplit: Int) -> [String] {
        return characters.split(separator: separator, maxSplits: maxSplit, omittingEmptySubsequences: allowEmptySlices).map { String($0) }
    }
    
    func splitBy(separator: Character, allowEmptySlices: Bool = false) -> [String] {
        return characters.split(separator: separator, omittingEmptySubsequences: allowEmptySlices).map { String($0) }
    }
}

public struct DefaultSerializer: SerializerType {
    public init(){}

    public func serialize(_ src: [String: String]) throws -> String {
        return src.map({ k, v in "\(k)=\(v)" }).joined(separator: "&")
    }

    public func deserialize(_ src: String) throws -> [String: String] {
        var dict: [String: String] = [:]
        src.splitBy(separator: "&", maxSplit: 1).forEach { elem in
            let splited = elem.splitBy(separator: "=", maxSplit: 1)
            dict[splited[0]] = splited[1]
        }

        return dict
    }
}
