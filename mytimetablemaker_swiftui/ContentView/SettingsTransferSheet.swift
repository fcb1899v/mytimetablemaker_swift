//
//  SettingsTransferSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/08/21.
// 
//  Sheet view for configuring transfer time and transportation methods in settings.
//  Provides functionality to set transfer times and select transportation methods for line changes.
//  Features include time range selection, transportation method toggles, and persistent storage.
//

import SwiftUI
import Foundation

// MARK: - SettingsTransferSheet
// Main view for configuring transfer settings including time ranges and transportation methods.
struct SettingsTransferSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: SettingsTransferSheetViewModel
    
    // MARK: - Initialization
    // Initialize the view with direction and line index for proper data isolation.
    init(goorback: String, lineIndex: Int) {
        self._vm = StateObject(wrappedValue: SettingsTransferSheetViewModel(goorback: goorback, lineIndex: lineIndex))
    }
    
    // MARK: - Body
    // Main view layout with header and scrollable content sections.
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Transportation Settings
                // Configuration interface for transportation method preferences.
                HStack {
                    Text("Next Transfer".localized)
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
                            ForEach(TransportationType.allCases.reversed(), id: \.self) { type in
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

                    Spacer()
                }

                // MARK: - Transfer Time Settings
                // Configuration interface for transfer time.
                if vm.selectedTransportation != "none" {
                    HStack {
                        Text("Transfer Time".localized)
                            .font(.headline)
                            .foregroundColor(Color.primaryColor)
                        
                        HStack {
                            Text("\(vm.selectedTransferTime)" + " min".localized)
                                .foregroundColor(.black)
                            
                            Menu {
                                ForEach(0...99, id: \.self) { minute in
                                    Button("\(minute)" + " min".localized) {
                                        vm.selectedTransferTime = minute
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
                }
                
                // MARK: - Save Button
                // Save button for transfer settings
                Button(action: {
                    vm.saveSettings()
                    
                    // Post notification to update MainContentView
                    NotificationCenter.default.post(name: NSNotification.Name("SettingsLineUpdated"), object: nil)
                    
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.title3)
                        Text("Save".localized)
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
                    Button("Cancel".localized) {
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

// MARK: - SettingsTransferSheetViewModel
// View model for managing transfer settings data and business logic.
class SettingsTransferSheetViewModel: ObservableObject {
    // MARK: - Published Properties
    // Observable properties that trigger UI updates when changed
    @Published var selectedTransferTime: Int = 5                      // Acceptable transfer time in minutes
    @Published var selectedTransportation: String = "none"            // Selected transportation method (default: none)
    
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
    // Load saved settings from persistent storage.
    func loadSettings() {
        // Load transportation from UserDefaults first
        let savedTransportation = UserDefaults.standard.string(forKey: goorback.transportationKey(lineIndex + 2))
        if let saved = savedTransportation, !saved.isEmpty {
            selectedTransportation = saved
        } else {
            // Check if there's a transfer count indicating a transfer is needed
            let savedTransferCount = UserDefaults.standard.integer(forKey: goorback.changeLineKey)
            if savedTransferCount > lineIndex {
                // If transfer count is greater than line index, default to "walking"
                selectedTransportation = "walking"
            } else {
                // If no transfer count or transfer not needed, default to "none"
                selectedTransportation = "none"
            }
        }
        
        // Load transfer time from UserDefaults only if transportation is not "none"
        if selectedTransportation != "none" {
            let savedTransferTime = UserDefaults.standard.integer(forKey: goorback.transferTimeKey(lineIndex + 2))
            if savedTransferTime > 0 {
                selectedTransferTime = savedTransferTime 
            } else {
                // If no saved transfer time, default to 5 minutes
                selectedTransferTime = 5
            }
        }
    }
    
    // MARK: - Data Saving
    // Save current settings to persistent storage.
    func saveSettings() {
        UserDefaults.standard.set(selectedTransferTime, forKey: goorback.transferTimeKey(lineIndex + 2))
        UserDefaults.standard.set(selectedTransportation, forKey: goorback.transportationKey(lineIndex + 2))
        
        // Calculate and save transfer count
        let transferCount = selectedTransportation == "none" ? lineIndex : lineIndex + 1
        UserDefaults.standard.set(transferCount, forKey: goorback.changeLineKey)
    }
}



// MARK: - Preview
// SwiftUI preview for development and testing
struct SettingsTransferSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTransferSheet(goorback: "back1", lineIndex: 0)
    }
}


