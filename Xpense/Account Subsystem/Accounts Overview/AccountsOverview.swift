//
//  AccountsOverview.swift
//  Xpense
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha on 13/03/23.
//  Copyright © 2023 TUM LS1. All rights reserved.
//

import SwiftUI
import XpenseModel


// MARK: - AccountsOverview
/// An overview of all `Account`s the Xpense Application
struct AccountsOverview: View {
    @EnvironmentObject
    var model: Model

    var body: some View {
        ContentCoordinator(content: content, contentType: .accountLink())
        .tabItem {
            Image(systemName: "rectangle.stack")
            Text("Accounts")
        }
    }
    
    /// Button that is used to add a new `Account`
    @ViewBuilder private func content(path: Binding<[ContentLink]>) -> some View {
        ScrollView(.vertical) {
            AccountsBalance()
                .padding(.bottom, 8)
            AccountsGrid(path: path)
                .padding(.bottom, 16)
        }.backgroundViewModifier()
        // TODO 3.3: Add a task modifier above to call refreshAccounts() on the model
    }
}


// MARK: - AccountsView Previews
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsOverview()
            .environmentObject(MockModel() as Model)
    }
}
