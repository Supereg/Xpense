//
//  RestfulModel.swift
//  XpenseModel
//
//  Created by Paul Schmiedmayer on 03/14/20.
//  Rewritten by Daniel Nugraha on 08.03.23.
//  Copyright © 2023 TUM LS1. All rights reserved.
//

import Foundation


// MARK: RestfulModel
/// Handles storing and loading Xpense relevant data from and to a RESTful server.
@available(iOS 16.0, *)
public class RestfulModel: Model {
    /// The base route that is used to access the RESTful server
    static let baseURL: URL = {
        guard let baseURL = URL(string: "http://127.0.0.1:8080/v1/") else {
            fatalError("Could not create the base URL for the Xpense Server")
        }
        return baseURL
    }()
    
    public override func save(_ account: Account) async {
        do {
            try await saveElement(account, to: \.accounts)
        } catch {
            await setServerError(to: .saveFailed(Account.self))
            return
        }
        
        await refresh()
    }
    
    public override func save(_ transaction: Transaction) async {
        do {
            try await saveElement(transaction, to: \.transactions)
        } catch {
            await setServerError(to: .saveFailed(Transaction.self))
            return
        }
        
        await refresh()
    }
    
    public override func delete(account id: Account.ID) async {
        do {
            try await delete(id, in: \.accounts)
        } catch {
            await setServerError(to: .deleteFailed(Account.self))
            return
        }
        
        await refresh()
    }
    
    public override func delete(transaction id: Transaction.ID) async {
        do {
            try await delete(id, in: \.transactions)
        } catch {
            await setServerError(to: .deleteFailed(Account.self))
            return
        }
        
        await refresh()
    }
    
    public override func signUp(_ name: String, password: String) async {
        do {
            try await sendSignUpRequest(name, password: password)
        } catch {
            await setServerError(to: .signUpFailed)
            return
        }
        do {
            try await sendLoginRequest(name, password: password)
        } catch {
            await setServerError(to: .loginFailed)
        }

        // TODO Task 3.1: remove this call to refresh
        await refresh()
    }

    public override func login(_ name: String, password: String) async {
        do {
            try await sendLoginRequest(name, password: password)
        } catch {
            await setServerError(to: .loginFailed)
        }

        // TODO Task 3.2: remove this call to refresh
        await refresh()
    }

    override func loadAccounts() async throws -> [Account] {
        try await Account.get()
    }

    override func loadTransactions() async throws -> [Transaction] {
        try await Transaction.get()
    }
}
