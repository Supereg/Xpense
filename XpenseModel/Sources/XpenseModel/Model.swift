//  XpenseModel
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha on 06/03/23.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: Model
/// The model of the Xpense App
@available(iOS 16.0, *)
public class Model: ObservableObject {
    /// The `User` of the Xpense App
    @Published public internal(set) var user: User?
    /// The `Account`s of the Xpense App
    @Published public internal(set) var accounts: [Account]
    /// The `Transaction`s of the Xpense App
    @Published public internal(set) var transactions: [Transaction]
    /// A `XpenseServiceError` that should be displayed to the user in case of an error in relation with the Xpense Server
    @Published public internal(set) var serverError: XpenseServiceError?
    
    @Published public var path = NavigationPath()

    /// The current total balance of all `Account`s that are stored in the `Model` instance
    public var currentBalance: Transaction.Cent {
        accounts.reduce(0) { $0 + $1.balance(self) }
    }
    
    /// Initializes a new `Model` for the Xpense app
    /// - Parameters:
    ///    - user: The `User` of the Xpense App
    ///    - accounts: The `Account`s of the Xpense App
    ///    - transactions: The `Transaction`s of the Xpense App
    public init(user: User? = nil, accounts: [Account] = [], transactions: [Transaction] = []) {
        self.user = user
        self.accounts = accounts
        self.transactions = transactions
    }
    
    /// Get an `Account` for a specific ID
    /// - Parameters:
    ///    - id: The id of the `Account` you wish to find.
    /// - Returns: The corresponding `Account` if there exists one with the specified id, otherwise nil
    public func account(_ id: Account.ID?) -> Account? {
        accounts.first(where: { $0.id == id })
    }
    
    /// Get a `Transaction` for a specific ID
    /// - Parameters:
    ///    - id: The id of the `Transaction` you wish to find.
    /// - Returns: The corresponding `Transaction` if there exists one with the specified id, otherwise nil
    public func transaction(_ id: Transaction.ID?) -> Transaction? {
        transactions.first(where: { $0.id == id })
    }
    
    /// Save a specified `Account`.
    /// - Parameters:
    ///    - account: The `Account` you wish to save.
    /// - Returns: A `Future` that completes once the resonse from the server has arrived and has been processeds
    public func save(_ account: Account) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            var newAccount = account
            
            // Add an id in the case that the Transaction that should be saved is a new Transaction
            if newAccount.id == nil {
                newAccount.id = UUID()
            }
            
            self.accounts.replaceAndSort(newAccount)
        }
    }
    
    /// Save a specified `Transaction`.
    /// - Parameters:
    ///    - transaction: The `Transaction` you wish to save
    /// - Returns: A `Future` that completes once the resonse from the server has arrived and has been processed
    public func save(_ transaction: Transaction) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            var newTransaction = transaction
            
            // Add an id in the case that the Transaction that should be saved is a new Transaction
            if newTransaction.id == nil {
                newTransaction.id = UUID()
            }
            self.transactions.replaceAndSort(newTransaction)
        }
    }
    
    /// Delete a specified account and all transactions associated with the account.
    /// - Parameters:
    ///    - id: The id of the `Account` that you with to delete
    /// - Returns: A `Future` that completes once the resonse from the server has arrived and has been processed
    public func delete(account id: Account.ID) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            self.accounts.removeAll(where: { $0.id == id })
        }
    }
    
    /// Delete a specified transaction.
    /// - Parameters:
    ///    - id: The id of the `Transaction` that you with to delete
    /// - Returns: A `Future` that completes once the resonse from the server has arrived and has been processed
    public func delete(transaction id: Transaction.ID) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            self.transactions.removeAll(where: { $0.id == id })
        }
    }
    
    /// Provides the sign up functionality of the `Model`
    /// - Parameters:
    ///   - name: The name of the `User` that is used to authenticate the `User` in the future
    ///   - password: The password of the `User` that is used to authenticate the `User` in the future
    /// - Returns: A `Future` that completes once the resonse from the server has arrived and has been processed
    public func signUp(_ name: String, password: String) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            self.user = User(name: name)
        }
    }
    
    /// Provides the login functionality of the `Model`
    /// - Parameters:
    ///   - name: The name of the `User` that is used to authenticate the `User`
    ///   - password: The password of the `User` that is used to authenticate the `User`
    /// - Returns: A `Future` that completes once the resonse from the server has arrived and has been processed
    public func login(_ name: String, password: String) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            self.user = User(name: name, token: "SuperSecretToken")
        }
    }
    
    /// Logout the current `User` that is signed in and remove all personal data of the `User` stored in this `Model`
    public func logout() {
        user = nil
        accounts = []
        transactions = []
    }
    
    /// Call this method to indicate to the model that the server error has been displayed to the user
    public func resolveServerError() {
        serverError = nil
    }
}
