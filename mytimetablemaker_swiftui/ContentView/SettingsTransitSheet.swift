//
//  SettingsTransitSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/08/21.
//  Sheet view for configuring transit time and transportation methods in settings
//  This view provides functionality to set minimum and maximum transit times
//  and select preferred transportation methods for line changes.
//  Features include time range selection, transportation method toggles, and persistent storage.
//

import SwiftUI
import Foundation

// MARK: - SettingsTransitSheet
// Main view for configuring transit settings including time ranges and transportation methods
// Provides a clean interface for users to customize their transit preferences
struct SettingsTransitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: SettingsTransitSheetViewModel
    
    // MARK: - Initialization
    // Initialize the view with direction and line index for proper data isolation
    init(goorback: String, lineIndex: Int) {
        self._vm = StateObject(wrappedValue: SettingsTransitSheetViewModel(goorback: goorback, lineIndex: lineIndex))
    }
    
    // MARK: - Body
    // Main view layout with header and scrollable content sections
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Transit Time Settings
                // Configuration interface for transit time
                // Allows users to set the acceptable transit time
                // Picker for setting the acceptable transit time
                    HStack {
                        Text("乗換時間")
                            .font(.headline)
                            .foregroundColor(Color.primaryColor)
                        
                        HStack {
                            Text("\(vm.selectedTransitTime)分")
                                .foregroundColor(.black)
                            
                            Menu {
                                ForEach(0...99, id: \.self) { minute in
                                    Button("\(minute)分") {
                                        vm.selectedTransitTime = minute
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black)
                                    .padding(.leading, 8)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                        
                        Spacer()
                    }
                
                // MARK: - Transportation Settings
                // Configuration interface for transportation method preferences
                // Provides dropdown selection for various transportation options with visual indicators
                // Dropdown for selecting preferred transportation method
                    HStack {
                        Text("移動手段")
                            .font(.headline)
                            .foregroundColor(Color.primaryColor)
                        
                        HStack {
                            // Display icon for selected transportation method
                            Image(systemName: getTransportationType(label: vm.selectedTransportation).iconName)
                                .foregroundColor(.black)
                                .frame(width: 24)

                            Text(getTransportationType(label: vm.selectedTransportation).displayName)
                                .foregroundColor(.black)
                            
                            Menu {
                                ForEach(TransportationType.allCases, id: \.self) { type in
                                    Button(action: {
                                        vm.selectedTransportation = type.rawValue
                                    }) {
                                        HStack {
                                            Image(systemName: type.iconName)
                                                .foregroundColor(.black)
                                                .frame(width: 24)
                                            Text(type.displayName)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black)
                                    .padding(.leading, 8)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))

                    }
                
                // MARK: - Save Button
                // Save button for transit settings
                Button(action: {
                    vm.saveSettings()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.title3)
                        Text("保存")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor)
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            vm.loadSettings()
        }
    }
}

// MARK: - SettingsTransitSheetViewModel
// View model for managing transit settings data and business logic
// Handles data persistence, validation, and state management
class SettingsTransitSheetViewModel: ObservableObject {
    // MARK: - Published Properties
    // Observable properties that trigger UI updates when changed
    @Published var selectedTransitTime: Int = 5                       // Acceptable transit time in minutes
    @Published var selectedTransportation: String = "walking" // Selected transportation method (default: walking)
    
    // MARK: - Private Properties
    // Internal properties for data management and isolation
    private let goorback: String    // Direction identifier (go/back)
    private let lineIndex: Int      // Line index for UserDefaults key isolation
    
    // MARK: - Initialization
    // Initialize view model with direction and line index for proper data isolation
    init(goorback: String, lineIndex: Int) {
        self.goorback = goorback
        self.lineIndex = lineIndex
        loadSettings()
    }
    
    // MARK: - Data Loading
    // Load saved settings from persistent storage
    // Provides fallback to default values if no saved data exists
    func loadSettings() {
        // Load transit time from UserDefaults
        let savedTransitTime = UserDefaults.standard.integer(forKey: goorback.transitTimeKey(lineIndex))
        if savedTransitTime > 0 { selectedTransitTime = savedTransitTime }
        
        // Load transportation from UserDefaults
        let savedTransportation = UserDefaults.standard.string(forKey: goorback.transportationKey(lineIndex))
        if let saved = savedTransportation, !saved.isEmpty { selectedTransportation = saved }
    }
    
    // MARK: - Data Saving
    // Save current settings to persistent storage
    // Ensures user preferences are maintained across app sessions
    func saveSettings() {
        UserDefaults.standard.set(selectedTransitTime, forKey: goorback.transitTimeKey(lineIndex))
        UserDefaults.standard.set(selectedTransportation, forKey: goorback.transportationKey(lineIndex))
    }
}

// MARK: - TransportationType
// Enumeration of available transportation methods for transit
// Provides localized names, icons, and colors for UI representation
enum TransportationType: String, CaseIterable {
    case walking = "walking"    // Walking between stations
    case bicycle = "bicycle"    // Bicycle transportation
    case car = "car"            // Car transportation
    
    // MARK: - Display Properties
    // Localized display name for each transportation method
    var displayName: String {
        switch self {
            case .walking: return "Walking".localized
            case .bicycle: return "Bicycle".localized
            case .car: return "Car".localized
        }
    }
    
    // MARK: - Icon Properties
    // SF Symbol icon name for each transportation method
    var iconName: String {
        switch self {
            case .walking: return "figure.walk"
            case .bicycle: return "bicycle"
            case .car: return "car"
        }
    }
}

// MARK: - Utility Functions
// Helper function to convert string labels to TransportationType enum values
func getTransportationType(label: String) -> TransportationType {
    switch label {
        case "walking": return .walking
        case "bicycle": return .bicycle
        case "car": return .car
        default: return .walking
    }
}

// MARK: - Preview
// SwiftUI preview for development and testing
struct SettingsTransitSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTransitSheet(goorback: "back1", lineIndex: 0)
    }
}


