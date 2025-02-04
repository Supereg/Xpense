//
//  TransactionsOverview.swift
//  Xpense
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha on 13/03/23.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import SwiftUI
import XpenseModel


// MARK: - TransactionsOverview
/// View displaying all `Transactions` regardless of the account they belong to
struct TransactionsOverview: View {
    var body: some View {
        TransactionsList()
            .tabItem {
                Image(systemName: "list.dash")
                Text("Transactions")
            }
            .tag(2)
    }
}


// MARK: - TransactionsOverview Previews
struct TransactionsOverview_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsOverview()
            .environmentObject(MockModel() as Model)
    }
}
