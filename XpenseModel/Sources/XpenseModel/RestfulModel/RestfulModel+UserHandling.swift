//
//  RestfulModel+UserHandling.swift
//  XpenseModel
//
//  Created by Paul Schmiedmayer on 4/9/20.
//  Rewritten by Daniel Nugraha on 08.03.23.
//  Copyright © 2023 TUM LS1. All rights reserved.
//

import Foundation


// MARK: RestfulModel + User Handling
@available(iOS 16.0, *)
extension RestfulModel {
    /// Sends a sign in request to the Xpense Server and parses the corresponding response and updates the `Model`
    /// - Parameters:
    ///   - name: The name that should be used to sign in
    ///   - password: The password that should be used to sign in
    /// - Returns: An `AnyPublisher` that finishes once the sign in resonse arrived and the response was handled
    func sendSignUpRequest(_ name: String, password: String) async throws {
        let usersRoute = RestfulModel.baseURL.appendingPathComponent("users")
        _ = try await NetworkManager.postElement(
            SignUpMediator(name: name, password: password),
            on: usersRoute)
    }

    
    /// Sends a login request to the Xpense Server and parses the corresponding response and updates the `Model`
    /// - Parameters:
    ///   - name: The name that should be used to login
    ///   - password: The password that should be used to login
    /// - Returns: An `AnyPublisher` that finishes once the login resonse arrived and the response was handled
    func sendLoginRequest(_ name: String, password: String) async throws {
        let loginRoute = RestfulModel.baseURL.appendingPathComponent("login")
        guard let basicAuthToken = "\(name):\(password)".data(using: .utf8)?.base64EncodedString() else {
            throw XpenseServiceError.loginFailed
        }
        
        let userToken: User = try await NetworkManager.sendRequestAsync(
            NetworkManager.urlRequest("POST",
                       url: loginRoute,
                       authorization: "Basic \(basicAuthToken)"
            )
        )
        if let bearerToken = userToken.bearerToken {
            NetworkManager.authorization = bearerToken
        }
        
        DispatchQueue.main.async {
            self.user = userToken
        }
    }
}
