//
//  ContentView.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI
import UIKit

/// Main Content View
/// Displays the landing page as the entry point
struct ContentView: View {
    @State private var capturedImage: UIImage?
    
    var body: some View {
        LandingPageView(capturedImage: $capturedImage)
    }
}

#Preview {
    ContentView()
}
