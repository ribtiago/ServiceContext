//
//  Token.swift
//  
//
//  Created by Tiago Ribeiro on 03/01/2023.
//

import Foundation

public protocol Token {
    var accessToken: String { get }
    var type: TokenType { get }
    var expiresIn: Int { get }
}
