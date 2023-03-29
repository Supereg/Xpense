//
//  XpenseTests.swift
//  Xpense
//

import XCTest
import ViewInspector
import SwiftUI
@testable import Xpense
@testable import XpenseModel

class XpenseTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testRefresh() async {
        let loadAccountsCalled = expectation(description: "loadAccounts() runs immediately")
        let loadTransactionsCalled = expectation(description: "loadTransactions() runs immediately")
        
        let model = Model_RefreshMock(
            loadAccounts: {
                loadAccountsCalled.fulfill()
                try? await Task.sleep(nanoseconds: 100_000_000)
                return []
            },
            loadTransactions: {
                loadTransactionsCalled.fulfill()
                try? await Task.sleep(nanoseconds: 100_000_000)
                return []
            },
            refresh: {},
            refreshTransactions: {}
        )
        
        async let refresh: () = model.refresh()
        
        let _ = XCTWaiter.wait(
            for: [loadAccountsCalled, loadTransactionsCalled],
            timeout: 5 / 100
        )
        
        await refresh
    }
    
    func testRefreshCallsRemoved() async {
        let refreshCalled = expectation(description: "refresh() is not called by signUp() nor login()")
        refreshCalled.isInverted = true
        
        let restfulModel = RestfulModel_SignUpLoginMock(
            refresh: {
                refreshCalled.fulfill()
            }
        )
        
        await restfulModel.signUp("", password: "")
        await restfulModel.login("", password: "")
    
        await waitForExpectations(timeout: 0)
    }
    
    func testSendRequest() async {
        let successRequest = NetworkManager.urlRequest("GET", url: URL(string: "https://dummyjson.com/products/1")!)
        let failureRequest = NetworkManager.urlRequest("GET", url: URL(string: "https://googlee.de")!)
        
        do {
            let _: String = try await NetworkManager.sendRequestAsync(successRequest)
        } catch DecodingError.typeMismatch {
            // nop
        } catch {
            XCTFail("Request should have succeeded but failed \(error)")
        }
        
        do {
            let _: String = try await NetworkManager.sendRequestAsync(failureRequest)
            XCTFail("Request should have failed but didn't")
        } catch DecodingError.typeMismatch {
            XCTFail("Request should have failed but didn't")
        } catch {
            // nop
        }
    }
    
    @MainActor
    func testAccountsOverview() async {
        var callsToRefresh = 0
        
        let model = Model_RefreshMock(
            loadAccounts: { return [] },
            loadTransactions: { return [] },
            refresh: {
                callsToRefresh += 1
            },
            refreshTransactions: {}
        )
        
        var sut = AccountsOverview()
            .environmentObject(model as Model)
        
        ViewHosting.host(view: sut)
        ViewHosting.host(view: sut)
        
        try? await Task.sleep(for: Duration.milliseconds(500))
        
        if callsToRefresh == 0 {
            XCTFail("Initial refresh not called by AccountsOverview")
        } else if callsToRefresh > 1 {
            XCTFail("Multiple calls to refresh by AccountsOverview")
        }
    }
    
    @MainActor
    func testTransactionsOverview() async {
        var callsToRefreshTransactions = 0
        
        let model = Model_RefreshMock(
            loadAccounts: { return [] },
            loadTransactions: { return [] },
            refresh: {},
            refreshTransactions: {
                callsToRefreshTransactions += 1
            }
        )
        
        let sut = await TransactionsOverview()
            .environmentObject(model as Model)
        
        ViewHosting.host(view: sut)
        ViewHosting.host(view: sut)
        
        try? await Task.sleep(for: Duration.milliseconds(500))
        
        if callsToRefreshTransactions == 0 {
            XCTFail("Initial refreshTransactions() not called by TransactionsOverview")
        } else if callsToRefreshTransactions > 1 {
            XCTFail("Multiple calls to refreshTransactions() by TransactionsOverview")
        }
    }
}

class Model_RefreshMock: Model {
    let loadAccounts: () async -> [Account]
    let loadTransactions: () async -> [XpenseModel.Transaction]
    let refresh: () async -> Void
    let refreshTransactions: () async -> Void
    
    init(
        loadAccounts: @escaping () async -> [Account],
        loadTransactions: @escaping () async -> [XpenseModel.Transaction],
        refresh: @escaping () async -> Void,
        refreshTransactions: @escaping () async -> Void
    ) {
        self.loadAccounts = loadAccounts
        self.loadTransactions = loadTransactions
        self.refresh = refresh
        self.refreshTransactions = refreshTransactions
    }
    
    override func loadAccounts() async throws -> [Account] {
        await loadAccounts()
    }
    
    override func loadTransactions() async throws -> [XpenseModel.Transaction] {
        await loadTransactions()
    }
    
    override func refresh() async {
        self.didInitialAccountsRefresh = true
        await refresh()
    }
    
    override func refreshTransactions() async {
        self.didInitialTransactionsRefresh = true
        await refreshTransactions()
    }
}

class RestfulModel_SignUpLoginMock: RestfulModel {
    let refresh: () async -> Void
    
    init(
        refresh: @escaping () async -> Void
    ) {
        self.refresh = refresh
    }
    
    @objc
    override func sendSignUpRequest(_ name: String, password: String) async throws {
        // nop
    }
    
    @objc
    override func sendLoginRequest(_ name: String, password: String) async throws {
        // nop
    }
    
    override func refresh() async {
        await refresh()
    }
}
