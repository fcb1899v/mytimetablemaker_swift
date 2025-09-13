//
//  APITest.swift
//  mytimetablemaker_swiftuiTests
//
//  Created by Nakajima Masao Test on 2025/8/31.
//

import XCTest
@testable import mytimetablemaker_swiftui

class APITest: XCTestCase {
    
    // MARK: - Test Setup
    // Initialize test environment
    override func setUpWithError() throws {
        super.setUp()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    // MARK: - API Endpoint Tests
    // Test all API endpoints for data retrieval
    
    func testAllAPIEndpoints() throws {
        // Test each LocalDataSource case
        for dataSource in LocalDataSource.allCases {
            let url = dataSource.apiLink(for: dataSource.transportationType, isTimetable: false)
            XCTAssertFalse(url.isEmpty, "URL should not be empty for \(dataSource)")
            
            // Log the URL for verification
            print("Testing \(dataSource.operatorDisplayName): \(url)")
            
            // Test URL format
            XCTAssertTrue(url.hasPrefix("https://"), "URL should start with https:// for \(dataSource)")
            
            // Test URL contains required parameters
            if url.contains("acl:consumerKey") {
                XCTAssertTrue(url.contains("odpt:operator="), "URL should contain operator parameter for \(dataSource)")
            }
        }
    }
    
    // MARK: - Individual API Type Tests
    // Test each API type separately
    
    func testPublicAPIEndpoints() throws {
        let publicCases: [LocalDataSource] = [.toeiMetro, .toeiBus]
        
        for dataSource in publicCases {
            let url = dataSource.apiLink(for: .lineInfo)
            XCTAssertTrue(url.contains("api-public.odpt.org"), "Should use public API for \(dataSource)")
            XCTAssertFalse(url.contains("acl:consumerKey"), "Public API should not require consumer key for \(dataSource)")
        }
    }
    
    func testStandardAPIEndpoints() throws {
        let standardCases: [LocalDataSource] = [
            .tokyoMetro, .tokyu, .keikyu, .odakyu, .seibu, .sotetsu,
            .yokohamaMetro, .tsukuba, .tama, .yurikamome, .rinkai,
            .yokohamaBus, .tokyuBus, .seibuBus, .sotetsuBus, .kanachuBus, .kokusaiKogyo
        ]
        
        for dataSource in standardCases {
            let url = dataSource.apiLink(for: .lineInfo)
            XCTAssertTrue(url.contains("api.odpt.org"), "Should use standard API for \(dataSource)")
            XCTAssertTrue(url.contains("acl:consumerKey"), "Standard API should require consumer key for \(dataSource)")
        }
    }
    
    func testChallengeAPIEndpoints() throws {
        let challengeCases: [LocalDataSource] = [.jrEast, .tobu, .odakyuBus]
        
        for dataSource in challengeCases {
            let url = dataSource.apiLink(for: .lineInfo)
            XCTAssertTrue(url.contains("api-challenge.odpt.org"), "Should use challenge API for \(dataSource)")
            XCTAssertTrue(url.contains("acl:consumerKey"), "Challenge API should require consumer key for \(dataSource)")
        }
    }
    
    // MARK: - URL Format Tests
    // Test URL format and structure
    
    func testRailwayURLFormat() throws {
        let railwayCases: [LocalDataSource] = [
            .jrEast, .tokyoMetro, .toeiMetro, .tokyu, .keikyu, .odakyu, .tobu,
            .seibu, .sotetsu, .yokohamaMetro, .rinkai, .yurikamome, .tsukuba, .tama
        ]
        
        for dataSource in railwayCases {
            let url = dataSource.apiLink(for: .lineInfo)
            XCTAssertTrue(url.contains("odpt:Railway"), "Railway URL should contain odpt:Railway for \(dataSource)")
        }
    }
    
    func testBusURLFormat() throws {
        let busCases: [LocalDataSource] = [
            .toeiBus, .yokohamaBus, .tokyuBus, .odakyuBus, .seibuBus,
            .sotetsuBus, .kanachuBus, .kokusaiKogyo
        ]
        
        for dataSource in busCases {
            let url = dataSource.apiLink(for: .lineInfo)
            XCTAssertTrue(url.contains("odpt:BusroutePattern"), "Bus URL should contain odpt:BusroutePattern for \(dataSource)")
        }
    }
    
    // MARK: - Operator Code Tests
    // Test operator codes are correctly formatted
    
    func testOperatorCodes() throws {
        for dataSource in LocalDataSource.allCases {
            let operatorCode = dataSource.operatorCode
            XCTAssertTrue(operatorCode.hasPrefix("odpt.Operator:"), "Operator code should start with 'odpt.Operator:' for \(dataSource)")
            XCTAssertFalse(operatorCode.isEmpty, "Operator code should not be empty for \(dataSource)")
        }
    }
    
    // MARK: - Transportation Type Tests
    // Test transportation type classification
    
    func testTransportationTypes() throws {
        let railwayCases: [LocalDataSource] = [
            .jrEast, .tokyoMetro, .toeiMetro, .tokyu, .keikyu, .odakyu, .tobu,
            .seibu, .sotetsu, .yokohamaMetro, .rinkai, .yurikamome, .tsukuba, .tama
        ]
        
        let busCases: [LocalDataSource] = [
            .toeiBus, .yokohamaBus, .tokyuBus, .odakyuBus, .seibuBus,
            .sotetsuBus, .kanachuBus, .kokusaiKogyo
        ]
        
        for dataSource in railwayCases {
            XCTAssertEqual(dataSource.transportationType, .railway, "\(dataSource) should be classified as railway")
        }
        
        for dataSource in busCases {
            XCTAssertEqual(dataSource.transportationType, .bus, "\(dataSource) should be classified as bus")
        }
    }
}

