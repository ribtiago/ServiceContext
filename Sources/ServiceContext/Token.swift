//
//  Token.swift
//

import Foundation

public protocol Token {
    var accessToken: String { get }
    var type: TokenType { get }
    var expiresIn: Int { get }
}
