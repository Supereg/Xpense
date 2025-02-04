//
//  EditAccount.swift
//  Xpense
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Rewritten by Daniel Nugraha 9/3/23.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import SwiftUI
import XpenseModel


// MARK: - EditAccount
/// A view that enables the user to edit an `Account`
struct EditAccount: View {
    
    /// The `EditAccountViewModel` that manages the content of the view
    @ObservedObject private var viewModel: EditAccountViewModel
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Account Name", text: $viewModel.name)
                }
                if viewModel.id != nil {
                    DeleteButton(viewModel: viewModel)
                }
            }.task {
                viewModel.updateStates()
            }
                .navigationBarTitle(viewModel.id == nil ? "Add Account" : "Edit Account", displayMode: .inline)
                .toolbar {
                    SaveButton(viewModel: viewModel)
                        .alert(isPresented: viewModel.presentingErrorMessage) {
                            Alert(title: Text("Error"),
                                  message: Text(viewModel.errorMessage ?? ""))
                        }
                }
        }
    }
    
    
    /// - Parameter model: The `Model` that is used to manage the `Account`s of the Xpense Application
    /// - Parameter id: The `Account`'s identifier that should be edited
    init(_ model: Model, id: XpenseModel.Transaction.ID) {
        viewModel = EditAccountViewModel(model, id: id)
    }
}


// MARK: - DeleteButton
/// A button that deletes an `Account` used in the `EditAccount` view
private struct DeleteButton: View {
    /// Indicates whether this `EditAccount` view is currently presented
    @Environment(\.presentationMode) private var presentationMode
    
    /// The `EditAccountViewModel` that manages the content of the view
    @ObservedObject var viewModel: EditAccountViewModel
    
    
    var body: some View {
        Button(action: { viewModel.showDeleteAlert = true }) {
            HStack {
                Spacer()
                Text("Delete")
                Spacer()
            }
        }.buttonStyle(ProgressViewButtonStyle(animating: $viewModel.showDeleteProgressView,
                                              progressViewColor: .gray,
                                              foregroundColor: .red))
            .alert(isPresented: $viewModel.showDeleteAlert) {
                deleteAlert
            }
    }
    
    /// Alter that is used to verify that the user really wants to delete the `Account`
    private var deleteAlert: Alert {
        Alert(title: Text("Delete Account"),
              message: Text("If you delete the Account you will also delete all Transactions associated with the Account"),
              primaryButton: .destructive(Text("Delete"), action: delete),
              secondaryButton: .cancel())
    }
    
    
    /// Uses the `EditAccountViewModel` to delete the account
    private func delete() {
        Task.init {
            await viewModel.delete()
            presentationMode.wrappedValue.dismiss()
        }
    }
}


// MARK: - EditAccount Previews
struct EditAccount_Previews: PreviewProvider {
    private static let model: Model = MockModel()
    
    
    static var previews: some View {
        EditAccount(model, id: model.accounts[0].id)
            .environmentObject(model)
    }
}
