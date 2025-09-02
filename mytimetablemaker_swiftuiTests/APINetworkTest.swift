//
//  APINetworkTest.swift
//  mytimetablemaker_swiftuiTests
//
//  Created by Nakajima Masao on 2025/08/31.
//

import XCTest
@testable import mytimetablemaker_swiftui

final class APINetworkTest: XCTestCase {
    
    // MARK: - API Response Test
    // Test actual API responses for all endpoints
    func testAPIResponseForAllEndpoints() async throws {
        let net = ODPTNetworkClient()
        let consumerKey = "h34l1u19vxxa3itym1sa3n2qiufokufo543zfifwbuenj3dtpwthnf91k8u4lyra"
        
        print("🚀 Testing API Endpoints using Enums.swift LocalDataSource")
        print(String(repeating: "=", count: 60))
        
        for dataSource in LocalDataSource.allCases {
            let url = dataSource.lineInfomationLink
            print("📡 \(dataSource.displayName): \(url)")
            
            guard let requestURL = URL(string: url) else {
                print("❌ Invalid URL format")
                continue
            }
            
            var request = URLRequest(url: requestURL)
            request.timeoutInterval = 10.0
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let semaphore = DispatchSemaphore(value: 0)
            var responseStatus: Int?
            var responseData: Data?
            var responseError: Error?
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                responseData = data
                responseError = error
                
                if let httpResponse = response as? HTTPURLResponse {
                    responseStatus = httpResponse.statusCode
                }
                
                semaphore.signal()
            }
            
            task.resume()
            
            let result = semaphore.wait(timeout: .now() + 15.0)
            
            if result == .timedOut {
                print("⏰ Timeout")
            } else if let error = responseError {
                print("❌ Network error: \(error.localizedDescription)")
            } else if let status = responseStatus {
                switch status {
                case 200:
                    if let data = responseData, !data.isEmpty {
                        print("✅ \(dataSource.displayName): Success")
                        print("📦 \(dataSource.displayName): Received \(data.count) bytes")
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            if let jsonArray = json as? [[String: Any]] {
                                print("📊 \(dataSource.displayName): Received \(jsonArray.count) items")
                            }
                        } catch {
                            print("❌ JSON parsing error: \(error.localizedDescription)")
                        }
                    } else {
                        print("⚠️ Success but no data received")
                    }
                case 304:
                    print("🔄 \(dataSource.displayName): Not Modified (304) - Using cached data")
                case 401:
                    print("🔑 Authentication required (401) - Expected for protected endpoints")
                case 403:
                    print("🚫 Access forbidden (403) - API key may be invalid")
                case 404:
                    print("❌ Endpoint not found (404)")
                default:
                    print("❌ HTTP \(status)")
                }
            }
            
            print("")
        }
        
        print("✅ API Endpoint Test Complete")
    }
    
    // MARK: - Documents Directory Save Test
    // Test if data is actually saved to Documents directory
    func testDocumentsDirectorySave() async throws {
        let net = ODPTNetworkClient()
        let consumerKey = "h34l1u19vxxa3itym1sa3n2qiufokufo543zfifwbuenj3dtpwthnf91k8u4lyra"
        
        print("📁 Testing Documents Directory Save")
        print(String(repeating: "=", count: 50))
        
        // Test railways data save
        let result = await net.updateSingleSource(.railways, consumerKey: consumerKey)
        
        switch result {
        case .success():
            print("✅ Railways data update completed")
            
            // Check if file exists in Documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let lineDataPath = documentsPath.appendingPathComponent("LineData", isDirectory: true)
            let railwaysFile = lineDataPath.appendingPathComponent("railways_updated.json")
            
            if FileManager.default.fileExists(atPath: railwaysFile.path) {
                print("✅ File saved to Documents: \(railwaysFile.path)")
                
                // Check file size
                if let attributes = try? FileManager.default.attributesOfItem(atPath: railwaysFile.path),
                   let fileSize = attributes[.size] as? Int64 {
                    print("📦 File size: \(fileSize) bytes")
                }
                
                // Try to read the file
                if let data = try? Data(contentsOf: railwaysFile) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        if let jsonArray = json as? [[String: Any]] {
                            print("📊 File contains \(jsonArray.count) items")
                        }
                    } catch {
                        print("❌ Error parsing saved file: \(error)")
                    }
                }
            } else {
                print("❌ File not found in Documents directory")
            }
            
        case .failure(let error):
            print("❌ Update failed: \(error)")
        }
        
        print("")
    }
    
    // MARK: - 304 Response Test
    // Test if 304 responses are properly handled
    func test304ResponseHandling() async throws {
        let net = ODPTNetworkClient()
        let consumerKey = "h34l1u19vxxa3itym1sa3n2qiufokufo543zfifwbuenj3dtpwthnf91k8u4lyra"
        
        print("🔄 Testing 304 Response Handling")
        print(String(repeating: "=", count: 50))
        
        // First request to get data and cache it
        print("📡 First request (should get 200)")
        let firstResult = try await net.fetchWithUpdateIfNeeded(source: .railways, consumerKey: consumerKey)
        print("📦 First request result: \(firstResult.updated ? "Updated" : "Cached")")
        print("📊 Data size: \(firstResult.data.count) bytes")
        
        // Second request should get 304 if cache is valid
        print("📡 Second request (should get 304)")
        let secondResult = try await net.fetchWithUpdateIfNeeded(source: .railways, consumerKey: consumerKey)
        print("📦 Second request result: \(secondResult.updated ? "Updated" : "Cached")")
        print("📊 Data size: \(secondResult.data.count) bytes")
        
        // Check cache metadata
        let cache = CacheStore()
        if let meta = cache.loadMeta(for: "odpt_railways.meta.json") {
            print("📋 Cache metadata:")
            print("   ETag: \(meta.eTag ?? "None")")
            print("   Last-Modified: \(meta.lastModified ?? "None")")
            print("   Downloaded: \(meta.downloadedAt)")
        } else {
            print("❌ No cache metadata found")
        }
        
        print("")
    }
    
    // MARK: - Test All Transportation Operators Data
    func testAllTransportationOperatorsData() async throws {
        let net = ODPTNetworkClient()
        let consumerKey = "h34l1u19vxxa3itym1sa3n2qiufokufo543zfifwbuenj3dtpwthnf91k8u4lyra"
        
        print("🚇 Testing All Transportation Operators Data")
        print(String(repeating: "=", count: 60))
        
        // Get all LocalDataSource cases (22 operators total)
        let allOperators: [LocalDataSource] = LocalDataSource.allCases
        
        var totalDataSize: Int64 = 0
        var successfulUpdates = 0
        var failedUpdates = 0
        var railwayDataSize: Int64 = 0
        var busDataSize: Int64 = 0
        
        print("📊 Testing \(allOperators.count) transportation operators:")
        print("   Railways: \(allOperators.filter { $0.transportationType == .railway }.count)")
        print("   Buses: \(allOperators.filter { $0.transportationType == .bus }.count)")
        print("")
        
        for transportOperator in allOperators {
            print("🔄 Testing \(transportOperator.displayName) (\(transportOperator.transportationType == .railway ? "🚇" : "🚌"))...")
            
            do {
                // Test individual operator data by making direct API calls
                let urlString = transportOperator.lineInfomationLink
                guard let url = URL(string: urlString) else {
                    print("  ❌ Invalid URL for \(transportOperator.displayName)")
                    failedUpdates += 1
                    continue
                }
                
                var request = URLRequest(url: url)
                request.setValue(consumerKey, forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        successfulUpdates += 1
                        let dataSize = Int64(data.count)
                        totalDataSize += dataSize
                        
                        if transportOperator.transportationType == .railway {
                            railwayDataSize += dataSize
                        } else {
                            busDataSize += dataSize
                        }
                        
                        print("  ✅ \(transportOperator.displayName): \(dataSize) bytes")
                        
                        // Try to parse JSON to get item count
                        if let json = try? JSONSerialization.jsonObject(with: data),
                           let jsonArray = json as? [[String: Any]] {
                            print("     📊 Contains \(jsonArray.count) items")
                        }
                        
                    } else {
                        failedUpdates += 1
                        print("  ❌ \(transportOperator.displayName): HTTP \(httpResponse.statusCode)")
                    }
                }
                
                // Small delay to avoid overwhelming the API
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                
            } catch {
                failedUpdates += 1
                print("  ❌ \(transportOperator.displayName): Failed - \(error)")
            }
        }
        
        print(String(repeating: "-", count: 60))
        print("📈 Summary:")
        print("   Total operators tested: \(allOperators.count)")
        print("   Successful updates: \(successfulUpdates)")
        print("   Failed updates: \(failedUpdates)")
        print("   Railway data size: \(railwayDataSize) bytes (\(String(format: "%.2f", Double(railwayDataSize) / 1024 / 1024)) MB)")
        print("   Bus data size: \(busDataSize) bytes (\(String(format: "%.2f", Double(busDataSize) / 1024 / 1024)) MB)")
        print("   Total data size: \(totalDataSize) bytes (\(String(format: "%.2f", Double(totalDataSize) / 1024 / 1024)) MB)")
        
        // Check Documents directory for all saved files
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Documents directory not found")
            return
        }
        
        let lineDataDirectory = documentsDirectory.appendingPathComponent("LineData", isDirectory: true)
        
        if fileManager.fileExists(atPath: lineDataDirectory.path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: lineDataDirectory, includingPropertiesForKeys: [.fileSizeKey])
                let updatedFiles = files.filter { $0.lastPathComponent.contains("_updated.json") }
                
                print("📁 Files in Documents/LineData:")
                var documentsTotalSize: Int64 = 0
                
                for file in updatedFiles {
                    if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                       let fileSize = attributes[.size] as? Int64 {
                        documentsTotalSize += fileSize
                        print("   📄 \(file.lastPathComponent): \(fileSize) bytes")
                    }
                }
                
                print("   📦 Total Documents size: \(documentsTotalSize) bytes (\(String(format: "%.2f", Double(documentsTotalSize) / 1024 / 1024)) MB)")
                
            } catch {
                print("❌ Error reading Documents directory: \(error)")
            }
        } else {
            print("📁 LineData directory not found in Documents")
        }
        
        print("")
    }
    
    // MARK: - 304 Response Test for All Operators
    // Test if 304 responses are properly handled for all 22 operators
    func test304ResponseHandlingForAllOperators() async throws {
        let net = ODPTNetworkClient()
        let consumerKey = "h34l1u19vxxa3itym1sa3n2qiufokufo543zfifwbuenj3dtpwthnf91k8u4lyra"
        
        print("🔄 Testing 304 Response Handling for All 22 Operators")
        print(String(repeating: "=", count: 70))
        
        // Get all LocalDataSource cases using allCases
        let allOperators: [LocalDataSource] = LocalDataSource.allCases
        
        var successfulTests = 0
        var failedTests = 0
        var totalDataSize: Int64 = 0
        
        print("📊 Testing \(allOperators.count) operators for 304 response handling")
        print("")
        
        for transportOperator in allOperators {
            print("🔄 Testing \(transportOperator.displayName) (\(transportOperator.transportationType == .railway ? "🚇" : "🚌"))...")
            
            do {
                // First request to get data and cache it
                let urlString = transportOperator.lineInfomationLink
                guard let url = URL(string: urlString) else {
                    print("  ❌ Invalid URL for \(transportOperator.displayName)")
                    failedTests += 1
                    continue
                }
                
                var request = URLRequest(url: url)
                request.setValue(consumerKey, forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                // First request
                let (firstData, firstResponse) = try await URLSession.shared.data(for: request)
                let firstHttpResponse = firstResponse as! HTTPURLResponse
                
                print("  📡 First request: \(firstHttpResponse.statusCode)")
                print("  📦 First data size: \(firstData.count) bytes")
                
                // Wait a moment to ensure cache is written
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                // Second request with conditional headers
                var secondRequest = URLRequest(url: url)
                secondRequest.setValue(consumerKey, forHTTPHeaderField: "Authorization")
                secondRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                
                // Add conditional headers if available
                if let etag = firstHttpResponse.value(forHTTPHeaderField: "ETag") {
                    secondRequest.setValue(etag, forHTTPHeaderField: "If-None-Match")
                }
                if let lastModified = firstHttpResponse.value(forHTTPHeaderField: "Last-Modified") {
                    secondRequest.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
                }
                
                let (secondData, secondResponse) = try await URLSession.shared.data(for: secondRequest)
                let secondHttpResponse = secondResponse as! HTTPURLResponse
                
                print("  📡 Second request: \(secondHttpResponse.statusCode)")
                print("  📦 Second data size: \(secondData.count) bytes")
                
                // Check if 304 response was received
                if secondHttpResponse.statusCode == 304 {
                    print("  ✅ 304 response received - cache working properly")
                    successfulTests += 1
                } else if secondHttpResponse.statusCode == 200 {
                    print("  ⚠️ 200 response received - data was updated")
                    successfulTests += 1
                } else {
                    print("  ❌ Unexpected status code: \(secondHttpResponse.statusCode)")
                    failedTests += 1
                }
                
                totalDataSize += Int64(firstData.count)
                
                // Show conditional headers used
                if let etag = firstHttpResponse.value(forHTTPHeaderField: "ETag") {
                    print("  🏷️ ETag: \(etag)")
                }
                if let lastModified = firstHttpResponse.value(forHTTPHeaderField: "Last-Modified") {
                    print("  📅 Last-Modified: \(lastModified)")
                }
                
            } catch {
                print("  ❌ Error testing \(transportOperator.displayName): \(error)")
                failedTests += 1
            }
            
            print("")
        }
        
        // Summary
        print("📊 304 Response Test Summary")
        print(String(repeating: "=", count: 50))
        print("✅ Successful tests: \(successfulTests)/\(allOperators.count)")
        print("❌ Failed tests: \(failedTests)/\(allOperators.count)")
        print("📦 Total data size: \(totalDataSize) bytes (\(String(format: "%.2f", Double(totalDataSize) / 1024 / 1024)) MB)")
        print("")
        
        // Verify cache metadata for a few operators
        let cache = CacheStore()
        print("📋 Cache Metadata Check")
        print(String(repeating: "-", count: 30))
        
        let testOperators = [LocalDataSource.jrEast, .tokyoMetro, .toeiBus]
        for transportOperator in testOperators {
            let fileName = "odpt_\(transportOperator.operatorCode.lowercased()).meta.json"
            if let meta = cache.loadMeta(for: fileName) {
                print("📄 \(transportOperator.displayName):")
                print("   ETag: \(meta.eTag ?? "None")")
                print("   Last-Modified: \(meta.lastModified ?? "None")")
                print("   Downloaded: \(meta.downloadedAt)")
            } else {
                print("📄 \(transportOperator.displayName): No cache metadata")
            }
        }
        
        print("")
    }
}

