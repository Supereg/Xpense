//
//  Transaction.swift
//  XpenseModel
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha on 08.03.23.
//  Copyright © 2023 TUM LS1. All rights reserved.
//

import Foundation
import SwiftUI


// MARK: - Transaction
/// Represents a single transaction of an `Account`
public struct Transaction {
    // MARK: - Cent
    /// The base type for all Currencies in the Xpense Application
    public typealias Cent = Int
    
    
    // MARK: - Classification
    /// Classifies `Transactions` into Incomes and Expenses.
    ///
    /// If the amount is greater or equal to the `Transaction` is going to be classified as an `income` otherwise it is an `expense`
    public enum Classification: String, CaseIterable, Identifiable {
        /// An Expense
        case expense = "Expense"
        /// An Income
        case income = "Income"
        
        
        public var id: String {
            self.rawValue
        }
        
        /// The factor that has to be applied to an amount to get the relative value of a `Transaction`
        ///
        /// 1 for an `Classification.income`
        ///
        ///  -1 for an `Classification.expense`
        public var factor: Int {
            self == .income ? 1 : -1
        }
        
        ///  A textual description of the `factor`
        ///
        ///  "" for an `Classification.income`
        ///
        ///  "-" for an `Classification.expense`
        public var sign: String {
            self == .income ? "" : "-"
        }
        
        ///  A color representing the `Classification`
        ///
        ///  green for an `Classification.income`
        ///
        ///  red for an `Classification.expense`
        public var color: Color {
            self == .income ? .green : .red
        }
        
        
        /// Create a new `Classification`
        /// - Parameter amount: The amount of the transaction.
        ///
        /// If the amount is greater or equal to the `Transaction` is going to be classified as an `income` otherwise it is an `expense`
        public init(_ amount: Cent) {
            self = amount < 0 ? .expense : .income
        }
    }
    
    
    /// The stable identity of the entity associated with self
    public var id: UUID?
    /// The amount of money this transaction is worth in `Cent`s
    public var amount: Cent
    /// A textual description of the `Transaction`
    public var description: String
    /// The date this `Transaction` was executed
    public var date: Date
    /// The location of the `Transaction` as a `Coordinate`
    public var location: Coordinate?
    /// The `Account` this `Transaction` is linked to
    public var account: UUID

    public var tags: [Tag]?
    
    /// Converts this `Transaction`'s amount into a textual representation
    public var amountDescription: String {
        NumberFormatter.currencyRepresentation(from: amount) ?? ""
    }
    
    /// Converts this `Transaction`'s date into a textual representation
    public var dateDescription: String {
        DateFormatter.dateAndTime.string(from: date)
    }
    
    /// Convert's this `Transaction`'s date into a relative description
    ///
    /// Example: 45 minutes ago
    public var relativeDateDescription: String {
        if let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff < 24 {
            return RelativeDateTimeFormatter.namedAndSpelledOut.localizedString(for: date, relativeTo: Date())
        }
        
        return DateFormatter.onlyDate.string(from: date)
    }
    
    /// This `Transaction`''s classification into expense or income
    public var classification: Classification {
        Classification(amount)
    }
    
    
    /// - Parameters:
    ///     - id: The stable identity of the `Transaction`
    ///     - amount: The amount of money this transaction is worth in `Cent`s
    ///     - description: A textual description of the `Transaction`
    ///     - date: The date this `Transaction` was executed
    ///     - location: The location of the `Transaction` as a `Coordinate`
    ///     - account: The `Account` this `Transaction` is linked to
    public init(id: UUID? = nil,
                amount: Cent,
                description: String,
                date: Date? = nil,
                location: Coordinate? = nil,
                account: UUID) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date ?? Date()
        self.location = location
        self.account = account
    }
}


// MARK: Transaction: Identifiable
extension Transaction: Identifiable { }


// MARK: Transaction: Hashable
extension Transaction: Hashable { }


// MARK: Transaction: Comparable
extension Transaction: Comparable {
    public static func < (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.date > rhs.date
    }
}

// MARK: Transaction: Restful
@available(iOS 16.0, *)
extension Transaction: Restful {
    static let route: URL = RestfulModel.baseURL.appendingPathComponent("transactions")
}
