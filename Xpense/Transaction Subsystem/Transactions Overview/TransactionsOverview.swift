//
//  TransactionsOverview.swift
//  Xpense
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha on 13/03/23.
//  Copyright © 2023 TUM LS1. All rights reserved.
//

import SwiftUI
import XpenseModel

// MARK: - TransactionsOverview
/// View displaying all `Transactions` regardless of the account they belong to
struct TransactionsOverview: View {
    @EnvironmentObject
    var model: Model
    
    var body: some View {
        ContentCoordinator(content: content, contentType: .transactionLink())
        .tabItem {
            Image(systemName: "list.dash")
            Text("Transactions")
        }
        // TODO 3.4: Add a task modifier above to call refreshTransactions() on the model
    }
    
    @ViewBuilder private func content(path: Binding<[ContentLink]>) -> some View {
        TransactionsList(path: path)
    }
}


// MARK: - TransactionsOverview Previews
struct TransactionsOverview_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsOverview()
            .environmentObject(MockModel() as Model)
    }
}
