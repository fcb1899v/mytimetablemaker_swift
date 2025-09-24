//
//  SettingsTransferSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/21.
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
    
    // MARK: - State Management
    @StateObject private var vm: SettingsTransferSheetViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization
    // Initialize the view with direction and line index for proper data isolation.
    init() {
        self._vm = StateObject(wrappedValue: SettingsTransferSheetViewModel())
    }
    
    // MARK: - Body
    // Main view layout with header and scrollable content sections.
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
                    
                    route2ToggleSection
                    
                    // Header section
                    headerSection(title: "Setting your home".localized)
                                        
                    // Home place input
                    placeInputSection(
                        title: "Your home".localized,
                        placeholder: "Enter your home".localized,
                        text: $vm.homeInput
                    )
                    
                    // Home transportation settings
                    // Route 1 row (or Route when Route 2 is hidden)
                    routeRow(
                        routeTitle: vm.showRoute2 ? "Route 1".localized : "Route".localized,
                        transportation: $vm.selectedHomeTransportation1,
                        transferTime: $vm.selectedHomeTransferTime1
                    )
                    
                    // Route 2 row (only shown when showRoute2 is true)
                    if vm.showRoute2 {
                        routeRow(
                            routeTitle: "Route 2".localized,
                            transportation: $vm.selectedHomeTransportation2,
                            transferTime: $vm.selectedHomeTransferTime2
                        )
                        .padding(.top, screen.settingsTransferSheetRoute2Spacing)
                    }
                    
                    // Destination section header
                    headerSection(title: "Setting destination".localized)
                    
                    // Destination place input
                    placeInputSection(
                        title: "Destination".localized,
                        placeholder: "Enter destination".localized,
                        text: $vm.officeInput
                    )
                    
                    // Destination transportation settings
                    // Route 1 row (or Route when Route 2 is hidden)
                    routeRow(
                        routeTitle: vm.showRoute2 ? "Route 1".localized : "Route".localized,
                        transportation: $vm.selectedOfficeTransportation1,
                        transferTime: $vm.selectedOfficeTransferTime1
                    )
                    
                    // Route 2 row (only shown when showRoute2 is true)
                    if vm.showRoute2 {
                        routeRow(
                            routeTitle: "Route 2".localized,
                            transportation: $vm.selectedOfficeTransportation2,
                            transferTime: $vm.selectedOfficeTransferTime2
                        )
                        .padding(.top, screen.settingsTransferSheetRoute2Spacing)
                    }
                    
                    // Save button
                    saveButtonSection()
                    
                    Spacer()
                }
            }
            .padding(.horizontal, screen.settingsSheetHorizontalPadding)
        }
        .onAppear {
            vm.loadSettings()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Home & Destination".localized)
                    .font(.system(size: screen.settingsTitleFontSize, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrowshape.backward.fill")
                            .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                            .foregroundColor(.black)
                        Text("Back to homepage".localized)
                            .font(.system(size: screen.settingsFontSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    // Route 2 Toggle Section
    private var route2ToggleSection: some View {
        HStack {
            Spacer()
            // Header section with Route 2 toggle
            CustomToggle(
                isLeftSelected: Binding(
                    get: { !vm.showRoute2 },
                    set: { vm.showRoute2 = !$0 }
                ),
                leftText: vm.showRoute2 ? "Display".localized: "Hide".localized,
                leftColor: vm.showRoute2 ? .primary: .gray,
                rightText: "Route 2".localized,
                rightColor: vm.showRoute2 ? .primary: .gray,
                circleColor: .white,
                offColor: vm.showRoute2 ? .primary: .gray
            )
        }
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    // Header section with title
    @ViewBuilder
    private func headerSection(title: String) -> some View {
        Text(title)
            .font(.system(size: screen.settingsSheetButtonFontSize, weight: .bold))
            .foregroundColor(.black)
    }
    
    // Place input section with title and text field
    @ViewBuilder
    private func placeInputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text(title)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: screen.settingsSheetInputFontSize))
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(CustomBackground())
                .overlay(CustomBorder())

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(text.wrappedValue.isEmpty ? .gray : .accent)
        }
    }
    
    /// Route row component with transportation method, time selector, and checkmark
    @ViewBuilder
    private func routeRow(
        routeTitle: String,
        transportation: Binding<String>,
        transferTime: Binding<Int>
    ) -> some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            
            VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
                
                Text(routeTitle)
                    .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primary)

                transportationMethodSelector(selectedTransportation: transportation)
                
                Spacer()
            }
            
            timeSelector(selectedTime: transferTime)
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor((transportation.wrappedValue.isEmpty || transferTime.wrappedValue == 0) ? .gray : .accent)
                .padding(.top, screen.settingsTransferSheetCheckmarkSpacing)
        }
    }
    
    /// Transportation method selector component
    @ViewBuilder
    private func transportationMethodSelector(selectedTransportation: Binding<String>) -> some View {
        HStack(spacing: screen.settingsSheetIconSpacing) {
            Image(systemName: getTransportationType(label: selectedTransportation.wrappedValue).iconName)
                .frame(height: screen.settingsSheetIconSize)
                .foregroundColor(.black)

            Text(getTransportationType(label: selectedTransportation.wrappedValue).transportationDisplayName)
                .font(.system(size: screen.settingsSheetInputFontSize))
                .foregroundColor(.black)
            
            Menu {
                ForEach(TransportationType.allCases.filter { $0 != .none }, id: \.self) { type in
                    Button(action: {
                        selectedTransportation.wrappedValue = type.rawValue
                    }) {
                        HStack(spacing: screen.settingsSheetIconSpacing) {
                            Image(systemName: type.iconName)
                                .foregroundColor(.black)
                                .frame(height: screen.settingsSheetIconSize)
                            Text(type.transportationDisplayName)
                                .font(.system(size: screen.settingsSheetInputFontSize))
                                .foregroundColor(.black)
                        }
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(height: screen.settingsSheetPickerDisplayHeight)
        .padding(.vertical, screen.settingsSheetInputPaddingVertical)
        .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
        .background(CustomBackground())
        .overlay(CustomBorder())
    }
    
    /// Time selector component using Custom2DigitPicker for better UX
    @ViewBuilder
    private func timeSelector(selectedTime: Binding<Int>) -> some View {
        ZStack {
            HStack {
                // Display current time value (always show "-" for 0)
                Text(selectedTime.wrappedValue == 0 ? "-" : "\(selectedTime.wrappedValue)\(" min".localized)")
                    .font(.system(size: screen.settingsSheetInputFontSize))
                    .foregroundColor(.black)
                Spacer()
            }
            .frame(height: screen.settingsSheetPickerDisplayHeight)
            .padding(.vertical, screen.settingsSheetInputPaddingVertical)
            .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
            .background(CustomBackground())
            .overlay(CustomBorder())
            
            HStack {
                Spacer()
                // Custom2DigitPicker for time selection (0-99 minutes)
                Custom2DigitPicker(value: selectedTime, isZeroToFive: false)
                    .frame(height: screen.settingsSheetPickerDisplayHeight)
            }
        }
        .padding(.top, screen.settingsTransferSheetPickerSpacing)
    }
    
    /// Save button section
    @ViewBuilder
    private func saveButtonSection() -> some View {
        CustomButton(
            title: "Save".localized,
            icon: "square.and.arrow.down.fill",
            backgroundColor: Color.accent,
            isEnabled: vm.isFormValid,
            action: {
                vm.saveSettings()
                
                // Post notification to update MainContentView
                NotificationCenter.default.post(name: NSNotification.Name("SettingsTransferUpdated"), object: nil)
                
                dismiss()
            }
        )
        .padding(.vertical, screen.settingsSheetVerticalSpacing)
    }
}

// MARK: - SettingsTransferSheetViewModel
// View model for managing transfer settings data and business logic.
class SettingsTransferSheetViewModel: ObservableObject {

    // MARK: - Published Properties
    // Observable properties that trigger UI updates when changed
    
    @Published var homeInput: String                      // home input text
    @Published var officeInput: String                    // office input text
    @Published var selectedHomeTransportation1: String    // Selected transportation 1 from home
    @Published var selectedHomeTransportation2: String    // Selected transportation 2 from home
    @Published var selectedOfficeTransportation1: String  // Selected transportation 1 from office
    @Published var selectedOfficeTransportation2: String  // Selected transportation 2 from office
    @Published var selectedHomeTransferTime1: Int         // Selected transfer time 1 from home
    @Published var selectedHomeTransferTime2: Int         // Selected transfer time 2 from home
    @Published var selectedOfficeTransferTime1: Int       // Selected transfer time 1 from office
    @Published var selectedOfficeTransferTime2: Int       // Selected transfer time 2 from office
    @Published var showRoute2: Bool                        // Flag to show/hide Route 2
    
    // MARK: - Initialization
    // Initialize view model with nil values if no saved data exists
    init() {
        self.homeInput = UserDefaults.standard.string(forKey: homeKey) ?? ""
        self.officeInput = UserDefaults.standard.string(forKey: officeKey) ?? ""
        self.selectedHomeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(0)) ?? ""
        self.selectedHomeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(0)) ?? ""
        self.selectedOfficeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(1)) ?? ""
        self.selectedOfficeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(1)) ?? ""
        
        // Initialize transfer times with 0 if no saved data exists
        let homeTime1 = UserDefaults.standard.object(forKey: "back1".transferTimeKey(0)) != nil ? 
            UserDefaults.standard.integer(forKey: "back1".transferTimeKey(0)) : 0
        self.selectedHomeTransferTime1 = homeTime1
        
        let homeTime2 = UserDefaults.standard.object(forKey: "back2".transferTimeKey(0)) != nil ? 
            UserDefaults.standard.integer(forKey: "back2".transferTimeKey(0)) : 0
        self.selectedHomeTransferTime2 = homeTime2
        
        let officeTime1 = UserDefaults.standard.object(forKey: "back1".transferTimeKey(1)) != nil ? 
            UserDefaults.standard.integer(forKey: "back1".transferTimeKey(1)) : 0
        self.selectedOfficeTransferTime1 = officeTime1
        
        let officeTime2 = UserDefaults.standard.object(forKey: "back2".transferTimeKey(1)) != nil ? 
            UserDefaults.standard.integer(forKey: "back2".transferTimeKey(1)) : 0
        self.selectedOfficeTransferTime2 = officeTime2
        
        // Initialize Route 2 visibility flag from MainContentView's UserDefaults keys
        // Use the same logic as MainContentView: isBack ? isShowBackRoute2: isShowGoRoute2
        let back2Route2Value = UserDefaults.standard.object(forKey: "back2".isShowRoute2Key) != nil ? 
            UserDefaults.standard.bool(forKey: "back2".isShowRoute2Key) : false
        let go2Route2Value = UserDefaults.standard.object(forKey: "go2".isShowRoute2Key) != nil ? 
            UserDefaults.standard.bool(forKey: "go2".isShowRoute2Key) : false
        
        // Use the same value for both routes (as per requirement)
        self.showRoute2 = back2Route2Value || go2Route2Value
    }

    // MARK: - Data Loading
    // Load saved settings from persistent storage with nil handling
    func loadSettings() {
        homeInput = UserDefaults.standard.string(forKey: homeKey) ?? ""
        officeInput = UserDefaults.standard.string(forKey: officeKey) ?? ""
        selectedHomeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(0)) ?? ""
        selectedHomeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(0)) ?? ""
        selectedOfficeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(1)) ?? ""
        selectedOfficeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(1)) ?? ""
        
        // Load transfer times with nil check
        selectedHomeTransferTime1 = UserDefaults.standard.object(forKey: "back1".transferTimeKey(0)) != nil ? 
            UserDefaults.standard.integer(forKey: "back1".transferTimeKey(0)) : 0
        selectedHomeTransferTime2 = UserDefaults.standard.object(forKey: "back2".transferTimeKey(0)) != nil ? 
            UserDefaults.standard.integer(forKey: "back2".transferTimeKey(0)) : 0
        selectedOfficeTransferTime1 = UserDefaults.standard.object(forKey: "back1".transferTimeKey(1)) != nil ? 
            UserDefaults.standard.integer(forKey: "back1".transferTimeKey(1)) : 0
        selectedOfficeTransferTime2 = UserDefaults.standard.object(forKey: "back2".transferTimeKey(1)) != nil ? 
            UserDefaults.standard.integer(forKey: "back2".transferTimeKey(1)) : 0
        // Load Route 2 visibility flag from MainContentView's UserDefaults keys
        // Use the same logic as MainContentView: isBack ? isShowBackRoute2: isShowGoRoute2
        let back2Route2Value = UserDefaults.standard.object(forKey: "back2".isShowRoute2Key) != nil ? 
            UserDefaults.standard.bool(forKey: "back2".isShowRoute2Key) : false
        let go2Route2Value = UserDefaults.standard.object(forKey: "go2".isShowRoute2Key) != nil ? 
            UserDefaults.standard.bool(forKey: "go2".isShowRoute2Key) : false
        
        // Use the same value for both routes (as per requirement)
        showRoute2 = back2Route2Value && go2Route2Value
    }
    
    // MARK: - Validation
    // Check if all required fields are filled for saving
    var isFormValid: Bool {
        return !homeInput.isEmpty &&
               !officeInput.isEmpty &&
               !selectedHomeTransportation1.isEmpty &&
               !selectedHomeTransportation2.isEmpty &&
               !selectedOfficeTransportation1.isEmpty &&
               !selectedOfficeTransportation2.isEmpty
    }
    
    // MARK: - Data Saving
    // Save current settings to persistent storage with validation
    func saveSettings() {
        // Validate form before saving
        guard isFormValid else {
            return
        }
        UserDefaults.standard.set(homeInput, forKey: homeKey)
        UserDefaults.standard.set(officeInput, forKey: officeKey)
        UserDefaults.standard.set(selectedHomeTransportation1, forKey: "back1".transportationKey(0))
        UserDefaults.standard.set(selectedHomeTransportation2, forKey: "back2".transportationKey(0))
        UserDefaults.standard.set(selectedOfficeTransportation1, forKey: "back1".transportationKey(1))
        UserDefaults.standard.set(selectedOfficeTransportation2, forKey: "back2".transportationKey(1))
        UserDefaults.standard.set(selectedHomeTransferTime1, forKey: "back1".transferTimeKey(0))
        UserDefaults.standard.set(selectedHomeTransferTime2, forKey: "back2".transferTimeKey(0))
        UserDefaults.standard.set(selectedOfficeTransferTime1, forKey: "back1".transferTimeKey(1))
        UserDefaults.standard.set(selectedOfficeTransferTime2, forKey: "back2".transferTimeKey(1))

        UserDefaults.standard.set(selectedHomeTransportation1, forKey: "go1".transportationKey(1))
        UserDefaults.standard.set(selectedHomeTransportation2, forKey: "go2".transportationKey(1))
        UserDefaults.standard.set(selectedOfficeTransportation1, forKey: "go1".transportationKey(0))
        UserDefaults.standard.set(selectedOfficeTransportation2, forKey: "go2".transportationKey(0))
        UserDefaults.standard.set(selectedHomeTransferTime1, forKey: "go1".transferTimeKey(1))
        UserDefaults.standard.set(selectedHomeTransferTime2, forKey: "go2".transferTimeKey(1))
        UserDefaults.standard.set(selectedOfficeTransferTime1, forKey: "go1".transferTimeKey(0))
        UserDefaults.standard.set(selectedOfficeTransferTime2, forKey: "go2".transferTimeKey(0))
        // Update MainContentView route2 visibility settings
        UserDefaults.standard.set(showRoute2, forKey: "back2".isShowRoute2Key)
        UserDefaults.standard.set(showRoute2, forKey: "go2".isShowRoute2Key)
    }
}

// MARK: - Preview
// SwiftUI preview for development and testing
struct SettingsTransferSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTransferSheet()
    }
}


