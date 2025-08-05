//
//  Config.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/07/31.
//  Copyright © 2025 com.nakajimamasao. All rights reserved.
//

import Foundation

// MARK: - Configuration Manager
// Manages application configuration from environment variables and .env file
struct Config {
    
    // MARK: - Environment Variable Helper
    // Retrieves environment variable value with .env file support
    private static func getEnvironmentVariable(_ key: String) -> String? {
        // First try to get from system environment variables
        if let envValue = ProcessInfo.processInfo.environment[key] {
            return envValue
        }
        
        // Then try to get from .env file
        return getValueFromEnvFile(key)
    }
    
    // MARK: - Default Ad Unit ID Helper
    // Returns appropriate ad unit ID based on build configuration
    private static func getDefaultAdUnitID() -> String {
        #if DEBUG
        // Use test ad ID for debug builds
        return "ca-app-pub-3940256099942544/2435281174"
        #else
        // Use production ad ID for release builds
        return getEnvironmentVariable("ADMOB_BANNER_UNIT_ID") ?? "ca-app-pub-1585283309075901/1821605177"
        #endif
    }
    
    // MARK: - .env File Helper
    // Reads values from .env file in the project root
    private static func getValueFromEnvFile(_ key: String) -> String? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Try to find .env file in various locations
        let possiblePaths = [
            documentsPath.appendingPathComponent(".env"),
            documentsPath.appendingPathComponent("../.env"),
            documentsPath.appendingPathComponent("../../.env")
        ]
        
        for path in possiblePaths {
            if let value = readValueFromFile(path: path, key: key) {
                return value
            }
        }
        
        return nil
    }
    
    // MARK: - File Reading Helper
    // Reads specific key-value pair from file
    private static func readValueFromFile(path: URL, key: String) -> String? {
        do {
            let content = try String(contentsOf: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip comments and empty lines
                if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                    continue
                }
                
                // Check if line contains the key
                if trimmedLine.hasPrefix("\(key)=") {
                    let value = String(trimmedLine.dropFirst(key.count + 1))
                    return value.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } catch {
            // File not found or cannot be read
            return nil
        }
        
        return nil
    }
    
    // MARK: - Public Configuration Properties
    
    /// AdMob Banner Unit ID for banner advertisements
    static var adMobBannerUnitID: String {
        return getEnvironmentVariable("ADMOB_BANNER_UNIT_ID") ?? getDefaultAdUnitID()
    }
} 