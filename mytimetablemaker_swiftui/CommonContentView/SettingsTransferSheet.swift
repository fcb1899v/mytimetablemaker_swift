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
            VStack(alignment: .leading) {
                
                // Header section
                headerSection(title: "Setting your home".localized)
                
                // Home place input
                placeInputSection(
                    title: "Your home".localized,
                    placeholder: "Enter your home".localized,
                    text: $vm.homeInput
                )
                
                // Home transportation settings
                transportationSettingsSection(
                    transportation1: $vm.selectedHomeTransportation1,
                    transportation2: $vm.selectedHomeTransportation2,
                    transferTime1: $vm.selectedHomeTransferTime1,
                    transferTime2: $vm.selectedHomeTransferTime2
                )
                
                // Destination section header
                headerSection(title: "Setting destination".localized)
                
                // Destination place input
                placeInputSection(
                    title: "Destination".localized,
                    placeholder: "Enter destination".localized,
                    text: $vm.officeInput
                )
                
                // Destination transportation settings
                transportationSettingsSection(
                    transportation1: $vm.selectedOfficeTransportation1,
                    transportation2: $vm.selectedOfficeTransportation2,
                    transferTime1: $vm.selectedOfficeTransferTime1,
                    transferTime2: $vm.selectedOfficeTransferTime2
                )
                
                // Save button
                saveButtonSection()
                
                Spacer()
            }
            .padding(.horizontal, screen.settingsLineSheetPadding)
        }
        .padding(.horizontal, screen.settingsLineSheetPadding)
        .onAppear {
            vm.loadSettings()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrowshape.backward.fill")
                            .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                            .foregroundColor(Color.black)
                        Text("Back to homepage".localized)
                            .font(.system(size: screen.settingsFontSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    // Header section with title
    @ViewBuilder
    private func headerSection(title: String) -> some View {
        Text(title)
            .font(.system(size: screen.settingsLineSheetHeaderFontSize, weight: .bold))
            .foregroundColor(Color.black)
            .padding(.vertical, screen.settingsLineSheetPadding)
    }
    
    // Place input section with title and text field
    @ViewBuilder
    private func placeInputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: screen.settingsLineSheetInputFontSize))
                .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                .background(styledBackground())
                .overlay(styledBorder())
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(text.wrappedValue.isEmpty ? .gray : .accentColor)
        }
    }
    
    /// Transportation settings grid section
    @ViewBuilder
    private func transportationSettingsSection(
        transportation1: Binding<String>,
        transportation2: Binding<String>,
        transferTime1: Binding<Int>,
        transferTime2: Binding<Int>
    ) -> some View {
        Grid(alignment: .center) {
            // Header row
            GridRow {
                Text("")
                    .font(.system(size: screen.settingsLineSheetInputFontSize))
                Text("Route 1".localized)
                    .font(.system(size: screen.settingsLineSheetInputFontSize))
                    .frame(maxWidth: .infinity)
                Text("Route 2".localized)
                    .font(.system(size: screen.settingsLineSheetInputFontSize))
                    .frame(maxWidth: .infinity)
            }

            // Transportation method row
            GridRow {
                Text("Transportation".localized)
                    .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primaryColor)

                transportationMethodSelector(selectedTransportation: transportation1)
                transportationMethodSelector(selectedTransportation: transportation2)
            }
            
            // Travel time row
            GridRow {
                Text("Travel Time".localized)
                    .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primaryColor)

                timeSelector(selectedTime: transferTime1)
                timeSelector(selectedTime: transferTime2)
            }
        }
        .padding(.vertical, screen.settingsLineSheetPadding)
    }
    
    /// Transportation method selector component
    @ViewBuilder
    private func transportationMethodSelector(selectedTransportation: Binding<String>) -> some View {
        HStack {
            Image(systemName: getTransportationType(label: selectedTransportation.wrappedValue).iconName)
                .foregroundColor(.black)
                .frame(width: screen.settingsLineSheetIconSize)
            
            Text(getTransportationType(label: selectedTransportation.wrappedValue).displayName)
                .font(.system(size: screen.settingsLineSheetInputFontSize))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Menu {
                ForEach(TransportationType.allCases.filter { $0 != .none }, id: \.self) { type in
                    Button(action: {
                        selectedTransportation.wrappedValue = type.rawValue
                    }) {
                        HStack {
                            Image(systemName: type.iconName)
                                .foregroundColor(.black)
                                .frame(width: screen.settingsLineSheetIconSize)
                            Text(type.displayName)
                                .font(.system(size: screen.settingsLineSheetInputFontSize))
                                .foregroundColor(.black)
                        }
                    }
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: screen.settingsLineSheetInputFontSize))
                    .foregroundColor(.black)
            }
        }
        .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
        .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
        .background(styledBackground())
        .overlay(styledBorder())
    }
    
    /// Time selector component
    @ViewBuilder
    private func timeSelector(selectedTime: Binding<Int>) -> some View {
        HStack {
            Text("\(selectedTime.wrappedValue)" + " min".localized)
                .font(.system(size: screen.settingsLineSheetInputFontSize))
                .foregroundColor(.black)
            
            Menu {
                ForEach(0...99, id: \.self) { minute in
                    Button("\(minute)" + " min".localized) {
                        selectedTime.wrappedValue = minute
                    }
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: screen.settingsLineSheetInputFontSize))
                    .foregroundColor(.black)
            }
        }
        .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
        .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
        .background(styledBackground())
        .overlay(styledBorder())
    }
    
    /// Save button section
    @ViewBuilder
    private func saveButtonSection() -> some View {
        Button(action: {
            vm.saveSettings()
            
            // Post notification to update MainContentView
            NotificationCenter.default.post(name: NSNotification.Name("SettingsLineUpdated"), object: nil)
            
            dismiss()
        }) {
            HStack {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .medium))
                Text("Save".localized)
                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: screen.settingsLineSheetButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: screen.settingsLineSheetButtonCornerRadius)
                    .fill(vm.officeInput.isEmpty ? .gray: Color.accentColor)
            )
            .padding(.vertical, screen.settingsLineSheetPadding)
        }
        .disabled(vm.homeInput.isEmpty || vm.officeInput.isEmpty)
    }
    
    // MARK: - Styling Helpers
    
    /// Styled background for input fields
    private func styledBackground() -> some View {
        RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius)
            .fill(Color(.secondarySystemBackground))
    }
    
    /// Styled border for input fields
    private func styledBorder() -> some View {
        RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius)
            .stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth)
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
    
    // MARK: - Initialization
    // Initialize view model with direction and line index for proper data isolation
    init() {
        self.homeInput = UserDefaults.standard.string(forKey: homeKey) ?? ""
        self.officeInput = UserDefaults.standard.string(forKey: officeKey) ?? ""
        self.selectedHomeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(0)) ?? "Walking".localized
        self.selectedHomeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(0)) ?? "Walking".localized
        self.selectedOfficeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(1)) ?? "Walking".localized
        self.selectedOfficeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(1)) ?? "Walking".localized
        
        let homeTime1 = UserDefaults.standard.integer(forKey: "back1".transferTimeKey(0))
        self.selectedHomeTransferTime1 = homeTime1 == 0 ? 10 : homeTime1
        
        let homeTime2 = UserDefaults.standard.integer(forKey: "back2".transferTimeKey(0))
        self.selectedHomeTransferTime2 = homeTime2 == 0 ? 10 : homeTime2
        
        let officeTime1 = UserDefaults.standard.integer(forKey: "back1".transferTimeKey(1))
        self.selectedOfficeTransferTime1 = officeTime1 == 0 ? 10 : officeTime1
        
        let officeTime2 = UserDefaults.standard.integer(forKey: "back2".transferTimeKey(1))
        self.selectedOfficeTransferTime2 = officeTime2 == 0 ? 10 : officeTime2
    }

    // MARK: - Data Loading
    // Load saved settings from persistent storage.
    func loadSettings() {
        homeInput = UserDefaults.standard.string(forKey: homeKey) ?? ""
        officeInput = UserDefaults.standard.string(forKey: officeKey) ?? ""
        selectedHomeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(0)) ?? "Walking".localized
        selectedHomeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(0)) ?? "Walking".localized
        selectedOfficeTransportation1 = UserDefaults.standard.string(forKey: "back1".transportationKey(1)) ?? "Walking".localized
        selectedOfficeTransportation2 = UserDefaults.standard.string(forKey: "back2".transportationKey(1)) ?? "Walking".localized
        selectedHomeTransferTime1 = UserDefaults.standard.integer(forKey: "back1".transferTimeKey(0))
        if selectedHomeTransferTime1 == 0 {
            selectedHomeTransferTime1 = 10
        }
        selectedHomeTransferTime2 = UserDefaults.standard.integer(forKey: "back2".transferTimeKey(0))
        if selectedHomeTransferTime2 == 0 {
            selectedHomeTransferTime2 = 10
        }
        selectedOfficeTransferTime1 = UserDefaults.standard.integer(forKey: "back1".transferTimeKey(1))
        if selectedOfficeTransferTime1 == 0 {
            selectedOfficeTransferTime1 = 10
        }
        selectedOfficeTransferTime2 = UserDefaults.standard.integer(forKey: "back2".transferTimeKey(1))
        if selectedOfficeTransferTime2 == 0 {
            selectedOfficeTransferTime2 = 10
        }
    }
    
    // MARK: - Data Saving
    // Save current settings to persistent storage.
    func saveSettings() {
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
    }
}

// MARK: - Preview
// SwiftUI preview for development and testing
struct SettingsTransferSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTransferSheet()
    }
}


