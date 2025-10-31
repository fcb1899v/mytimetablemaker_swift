//
//  NavigationBarModifier.swift
//  mytimetablemakers_swiftui
//
//  Created by Nakajima Masao on 2021/03/04.
//

import SwiftUI

// MARK: - Navigation Bar Modifier
// Custom view modifier for styling navigation bar appearance
struct NavigationBarModifier: ViewModifier {

    // Background color for the navigation bar
    var backgroundColor: UIColor?
    
    // Title text color for the navigation bar
    var titleColor: UIColor?

    // Initialize and configure navigation bar appearance
    init(backgroundColor: UIColor?, titleColor: UIColor?) {
        self.backgroundColor = backgroundColor
        
        // Configure navigation bar appearance for all appearance contexts
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]
        
        // Apply appearance to all navigation bar styles
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    // Apply modifier to content view
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    // Fill the safe area top with background color
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - View Extension
// Convenience extension for applying navigation bar styling
extension View {
    // Apply custom navigation bar colors to a view
    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }
}

