//
//  HistoryPlaceholderView.swift
//  SnapSort
//
//  Placeholder view for history screen
//  Will be implemented later to show past scans and data
//

import SwiftUI

struct HistoryPlaceholderView: View {
    var onBack: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack {
                // Header bar
                HStack {
                    // Back button
                    Button(action: {
                        print("DEBUG: History back button tapped")
                        onBack?()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Title
                    Text("History")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Spacer for alignment
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // Placeholder content
                VStack(spacing: 20) {
                    Image(systemName: "clock")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("History Coming Soon")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Your past scans and data will appear here")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    HistoryPlaceholderView()
}

