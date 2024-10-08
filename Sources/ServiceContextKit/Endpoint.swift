//
//  Endpoint.swift
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case put = "PUT"
}

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var usesToken: Bool { get }
    var subdomain: String? { get }
    var additionalHeaders: [String: String]? { get }
    var queryItems: [String: String]? { get }
    var timeoutInterval: TimeInterval? { get }
}

public extension Endpoint {
    var usesToken: Bool {
        return false
    }
    
    var subdomain: String? {
        return nil
    }
    
    var additionalHeaders: [String: String]? {
        return nil
    }
    
    var queryItems: [String: String]? {
        return nil
    }
    
    var timeoutInterval: TimeInterval? {
        return nil
    }
}

