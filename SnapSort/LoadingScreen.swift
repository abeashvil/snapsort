//
//  LoadingScreen.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI

/// Loading Screen (S-003)
/// Displays loading message and spinner
/// Shown while scanning the photo for items
struct LoadingScreen: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Loading spinner
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentColor)
            
            // Loading message
            Text("Scanning photo...")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoadingScreen()
}

