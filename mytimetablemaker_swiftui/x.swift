//
//  x.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//

import Foundation

// MARK: - Bus Data Loading Test
// Test script to verify bus data loading functionality

print("=== Bus Data Loading Test ===")

// Test loading all local data including bus data
let allLines = LocalFileLoader.loadLocalData()

// Count transportation types
var railwayCount = 0
var busCount = 0

for line in allLines {
    switch line.kind {
    case .railway:
        railwayCount += 1
    case .bus:
        busCount += 1
    }
}

print("Total transportation lines loaded: \(allLines.count)")
print("Railway lines: \(railwayCount)")
print("Bus routes: \(busCount)")

// Show some bus routes
print("\n=== Sample Bus Routes ===")
let busRoutes = allLines.filter { $0.kind == .bus }
for (index, route) in busRoutes.prefix(10).enumerated() {
    print("\(index + 1). \(route.name)")
    print("   Code: \(route.code)")
    print("   Operator: \(route.operatorCode ?? "Unknown")")
    print("   Pattern: \(route.pattern ?? "Unknown")")
    print("   Direction: \(route.direction ?? "Unknown")")
    print("   Start Station: \(route.startStation ?? "Unknown")")
    print("   End Station: \(route.endStation ?? "Unknown")")
    
    // Show bus stops
    if let busStops = route.busstopPoleOrder, !busStops.isEmpty {
        print("   Bus Stops (\(busStops.count)):")
        for (stopIndex, stop) in busStops.prefix(5).enumerated() {
            print("     \(stopIndex + 1). \(stop.note ?? "Unknown")")
        }
        if busStops.count > 5 {
            print("     ... and \(busStops.count - 5) more stops")
        }
    }
    print("---")
}

// Show some railway lines
print("\n=== Sample Railway Lines ===")
let railwayLines = allLines.filter { $0.kind == .railway }
for (index, line) in railwayLines.prefix(10).enumerated() {
    print("\(index + 1). \(line.name)")
    print("   Code: \(line.code)")
    print("   Operator: \(line.operatorCode ?? "Unknown")")
    print("   Color: \(line.lineColor ?? "Unknown")")
    print("   Start Station: \(line.startStation ?? "Unknown")")
    print("   End Station: \(line.endStation ?? "Unknown")")
    print("---")
}

print("\n=== Test Complete ===")

