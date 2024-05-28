//
//  APIManagerTests.swift
//  APIManagerTests
//
//  Created by Vicki Yang   on 2024/5/28.
//

import XCTest
@testable import Pokedex

final class APIManagerTests: XCTestCase {
    var apiManager: APIManager!
    
    override func setUp() {
        super.setUp()
        apiManager = APIManager.shared
    }
    
    override func tearDown() {
        apiManager = nil
        super.tearDown()
    }
    
    func testFetchPokemonListSuccess() {
        let expectation = XCTestExpectation(description: "Fetch Pokemon List")
        
        let limit = 10
        let offset = 30
        
        apiManager.fetchPokemonList(limit: limit, offset: offset) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.results.count, limit)
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
