//  XpenseModel
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha on 06/03/23.
//  Copyright © 2023 TUM LS1. All rights reserved.
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

    public internal(set) var didInitialAccountsRefresh: Bool = false
    public internal(set) var didInitialTransactionsRefresh: Bool = false

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

    /// Refresh `Accounts` from the backend.
    ///
    /// Note: This method must be overwritten by the concrete instantiation of the Model.
    /// - Returns: Returns the fetched list of accounts.
    /// - Throws: Throws an `XpenseServiceError` on any failure to fetch the latest state.
    public func refreshAccounts() async {
        do {
            let accounts = try await loadAccounts()
            await MainActor.run {
                self.accounts = accounts
                self.didInitialAccountsRefresh = true
            }
        } catch {
            await setServerError(to: .loadingFailed(Account.self))
        }
    }

    func loadAccounts() async throws -> [Account] {
        accounts
    }


    /// Refresh `Transaction` from the backend.
    ///
    /// Note: This method must be overwritten by the concrete instantiation of the Model.
    /// - Returns: Returns the fetched list of transactions.
    /// - Throws: Throws an `XpenseServiceError` on any failure to fetch the latest state.
    public func refreshTransactions() async {
        do {
            let transactions = try await loadTransactions()
            await MainActor.run {
                self.transactions = transactions
                self.didInitialTransactionsRefresh = true
            }
        } catch {
            await setServerError(to: .loadingFailed(Transaction.self))
        }
    }

    func loadTransactions() async throws -> [Transaction] {
        transactions
    }
    
    /// Save a specified `Account`.
    /// - Parameters:
    ///    - account: The `Account` you wish to save.
    /// - Returns: A `Future` that completes once the response from the server has arrived and has been processeds
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
    /// - Returns: A `Future` that completes once the response from the server has arrived and has been processed
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
    /// - Returns: A `Future` that completes once the response from the server has arrived and has been processed
    public func delete(account id: Account.ID) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            self.accounts.removeAll(where: { $0.id == id })
        }
    }
    
    /// Delete a specified transaction.
    /// - Parameters:
    ///    - id: The id of the `Transaction` that you with to delete
    /// - Returns: A `Future` that completes once the response from the server has arrived and has been processed
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
    /// - Returns: A `Future` that completes once the response from the server has arrived and has been processed
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
    /// - Returns: A `Future` that completes once the response from the server has arrived and has been processed
    public func login(_ name: String, password: String) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.async {
            self.user = User(name: name, token: "SuperSecretToken")
        }
    }

    /// Sets the `serverError` of the `Model` and returns the error to be processed by `Publishers`
    /// - Parameter error: The `XpenseServiceError` that should be set
    /// - Returns: The `XpenseServiceError` passed in as an argument
    @MainActor
    func setServerError(to error: XpenseServiceError) {
        self.serverError = error
    }

    /// Refreshes the `Accounts` and `Transaction` in the `Model`
    public func refresh() async {
        do {
            async let accountTask = try loadAccounts()
            async let transactionTask = try loadTransactions()

            let (accounts, transactions) = try await (accountTask, transactionTask)

            await MainActor.run {
                self.accounts = accounts
                self.transactions = transactions

                self.didInitialAccountsRefresh = true
                self.didInitialTransactionsRefresh = true
            }
        } catch {
            await setServerError(to: error as! XpenseServiceError)
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
