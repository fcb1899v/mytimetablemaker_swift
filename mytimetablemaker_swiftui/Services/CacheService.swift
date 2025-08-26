//
//  CacheService.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//
//  MARK: - Overview
//  Service for managing local cache storage and metadata.
//  Provides efficient data persistence and retrieval for offline access.
//

import Foundation

// MARK: - File Cache Management
// Handles local storage of ODPT data and metadata.
// Provides efficient data persistence and retrieval for offline access.
final class CacheStore {
    private let dir: URL
    
    init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        dir = base.appendingPathComponent("ODPTCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    // MARK: - File Path Management
    // Get file path for a given filename in the cache directory.
    private func path(for file: String) -> URL { dir.appendingPathComponent(file) }

    // MARK: - Data Operations
    // Load cached data from file system.
    func loadData(for file: String) -> Data? {
        let url = path(for: file)
        return try? Data(contentsOf: url)
    }
    
    // Save data to cache with atomic write for data integrity.
    func saveData(_ data: Data, for file: String) {
        let url = path(for: file)
        try? data.write(to: url, options: [.atomic])
    }

    // MARK: - Metadata Operations
    // Load cache metadata for validation and update checking.
    func loadMeta(for file: String) -> CacheMeta? {
        guard let data = loadData(for: file) else { return nil }
        return try? JSONDecoder().decode(CacheMeta.self, from: data)
    }
    
    // Save cache metadata for tracking data freshness.
    func saveMeta(_ meta: CacheMeta, for file: String) {
        let data = try? JSONEncoder().encode(meta)
        if let data { saveData(data, for: file) }
    }
}

// MARK: - Cache Meta Information
// Metadata for cached ODPT data including ETag and last modified information.
// Used for efficient cache validation and updates.
struct CacheMeta: Codable {
    var eTag: String?           // HTTP ETag for cache validation
    var lastModified: String?   // Last-Modified header value
    var downloadedAt: Date      // When the data was cached locally
}