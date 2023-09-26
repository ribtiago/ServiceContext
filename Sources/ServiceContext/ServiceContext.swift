//
//  ServiceContext.swift
//
//

import Foundation

public class ServiceContext {
    
    public enum Error: Swift.Error {
        case urlError
        case tokenNotFound
        case encodingError
        case httpError(code: Int)
    }
    
    let baseURL: String
    let urlSession: URLSession
    
    public var token: Token?
    
    public var isAuthenticated: Bool {
        return self.token != nil
    }
    
    public init(baseURL: String, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    public func request(_ endpoint: Endpoint) async throws {
        let request = try self.buildBaseRequest(for: endpoint)
        let (_, response) = try await self.urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard case 200..<300 = httpResponse.statusCode else {
            throw ServiceContext.Error.httpError(code: httpResponse.statusCode)
        }
    }
    
    public func request<DecodableObject: Decodable>(_ endpoint: Endpoint) async throws -> DecodableObject {
        let request = try self.buildBaseRequest(for: endpoint)
        let (data, response) = try await self.urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard case 200..<300 = httpResponse.statusCode else {
            throw ServiceContext.Error.httpError(code: httpResponse.statusCode)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DecodableObject.self, from: data)
    }
    
    public func request<DecodableObject: Decodable, EncodableObject: Encodable>(_ endpoint: Endpoint, body: EncodableObject) async throws -> DecodableObject {
        var request = try self.buildBaseRequest(for: endpoint)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        guard let httpBody = try? encoder.encode(body) else {
            throw ServiceContext.Error.encodingError
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let (data, response) = try await self.urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard case 200..<300 = httpResponse.statusCode else {
            throw ServiceContext.Error.httpError(code: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DecodableObject.self, from: data)
    }
    
    private func buildBaseRequest(for endpoint: Endpoint) throws -> URLRequest {
        var urlComponents = URLComponents(string: self.baseURL + endpoint.path)
        if let queryItems = endpoint.queryItems?.map({ URLQueryItem(name: $0.key, value: $0.value) }) {
            if urlComponents?.queryItems != nil {
                urlComponents?.queryItems?.append(contentsOf: queryItems)
            }
            else {
                urlComponents?.queryItems = queryItems
            }
        }
        
        guard let url = urlComponents?.url else {
            throw ServiceContext.Error.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if endpoint.usesToken {
            guard let token else {
                throw ServiceContext.Error.tokenNotFound
            }
            
            switch token.type {
            case .bearer:
                request.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
                
            case .idToken:
                request.addValue(token.accessToken, forHTTPHeaderField: "Authorization")
            }
        }
        
        if let additionalHeaders = endpoint.additionalHeaders {
            additionalHeaders.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
