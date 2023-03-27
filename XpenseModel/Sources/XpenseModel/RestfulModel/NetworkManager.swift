//
//  NetworkManager+Networking.swift
//  XpenseModel
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha on 08.03.23.
//  Copyright © 2023 TUM LS1. All rights reserved.
//

import Foundation

enum NetworkManager {
    /// The default `Authorization` header field for requests made by the `NetworkManager`
    static var authorization: String?
    
    /// The `JSONEncoder` that is used to encode request bodies to JSON
    static var encoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()
    
    /// The `JSONDecoder` that is used to decode response bodies to JSON
    static var decoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    /// Creates a `URLRequest` based on the parameters that has the `Content-Type` header field set to `application/json`
    /// - Parameters:
    ///   - method: The HTTP method
    ///   - url: The `URL` of the `URLRequest`
    ///   - authorization: The value that should be added the `Authorization` header field
    ///   - body: The HTTP body that should be added to the `URLRequest`
    /// - Returns: The created `URLRequest`
    static func urlRequest(_ method: String,
                           url: URL,
                           authorization: String? = authorization,
                           body: Data? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authorization = authorization {
            urlRequest.addValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpBody = body
        
        return urlRequest
    }
    
    /// Creates a `URLRequest` based on the parameters that has the `Content-Type` header field set to `application/json`
    /// - Parameters:
    ///   - urlRequest: The `URLRequest
    /// - Returns: The created `Element`
    static func sendRequest<Element: Decodable>(_ urlRequest: URLRequest) async throws -> Element {
        // TODO 2 Use `withCheckedThrowingContinuation` to write an async wrapper around the sendRequest method below,
        //  that still takes a completionHandler to call legacy API.
        fatalError("Task 2 is not implemented yet.")
    }

    static func sendRequest<Element: Decodable>(_ urlRequest: URLRequest, completionHandler: @escaping  (Result<Element, Error>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let response = response as? HTTPURLResponse,
                      200...299 ~= response.statusCode else {
                    completionHandler(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    let element = try decoder.decode(Element.self, from: data!)
                    completionHandler(.success(element))
                } catch {
                    completionHandler(.failure(error))
                }
            }.resume()
    }
    
    /// Gets a single `Element` from a `URL` specified by `route`
    /// - Parameters:
    ///     - route: The route to get the `Element` from
    ///     - authorization: The `String` that should written in the `Authorization` header field
    /// - Returns: An `AnyPublisher` that contains the `Element` from the server or or an `Error` in the case of an error
    static func getElement<Element: Decodable>(on route: URL,
                                               authorization: String? = authorization) async throws -> Element {
        
        try await sendRequestAsync(urlRequest("GET", url: route, authorization: authorization))
    }
    
    /// Gets a list of `Element`s from a `URL` specified by `route`
    /// - Parameters:
    ///     - route: The route to get the `Element`s from
    ///     - authorization: The `String` that should written in the `Authorization` header field
    /// - Returns: An `AnyPublisher` that contains an `Array` of  `Element` from the server or an empty `Array` in the case of an error
    static func getElements<Element: Decodable>(on route: URL,
                                                authorization: String? = authorization) async throws -> [Element] {
        try await getElement(on: route, authorization: authorization)
    }
    
    /// Creates an `Element`s to a `URL` specified by `route`
    /// - Parameters:
    ///     - element: The `Element` that should be created
    ///     - route: The route to get the `Element`s from
    ///     - authorization: The `String` that should written in the `Authorization` header field
    /// - Returns: An `AnyPublisher` that contains the created `Element` from the server or an `Error` in the case of an error
    static func postElement<Element: Codable>(_ element: Element,
                                        authorization: String? = authorization,
                                        on route: URL) async throws -> Element {
        try await sendRequestAsync(
            urlRequest("POST",
                       url: route,
                       authorization: authorization,
                       body: try? encoder.encode(element)
            )
        )
    }
    
    /// Updates an `Element`s to a `URL` specified by `route`
    /// - Parameters:
    ///     - element: The `Element` that should be updated
    ///     - route: The route to get the `Element`s from
    ///     - authorization: The `String` that should written in the `Authorization` header field
    /// - Returns: An `AnyPublisher` that contains the updated `Element` from the server or an `Error` in the case of an error
    static func putElement<Element: Codable>(_ element: Element,
                                       authorization: String? = authorization,
                                       on route: URL) async throws -> Element {
        try await sendRequest(
            urlRequest("PUT",
                       url: route,
                       authorization: authorization,
                       body: try? encoder.encode(element)
            )
        )
    }
    
    /// Deletes a Resource identified by an `URL` specified by `route`
    /// - Parameters:
    ///     - route: The route that identifies the resource
    ///     - authorization: The `String` that should written in the `Authorization` header field
    /// - Returns: An `AnyPublisher` that contains indicates of the deletion was successful
    static func delete(at route: URL,
                       authorization: String? = authorization) async throws {
        
        let (_, response) = try await URLSession.shared.data(for:
            urlRequest("DELETE", url: route, authorization: authorization)
        )
        
        guard
            let response = response as? HTTPURLResponse,
            200...299 ~= response.statusCode
        else {
            throw URLError(.cannotRemoveFile)
        }
        
    }
}

extension NetworkManager {
    /// Creates a `URLRequest` based on the parameters that has the `Content-Type` header field set to `application/json`
    /// - Parameters:
    ///   - urlRequest: The `URLRequest
    /// - Returns: The created `Element`
    static func sendRequestAsync<Element: Decodable>(_ urlRequest: URLRequest) async throws -> Element {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let response = response as? HTTPURLResponse,
              200...299 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(Element.self, from: data)
    }
}
