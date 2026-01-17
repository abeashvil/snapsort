//
//  ResultsScreen.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI

/// Results Screen (S-004)
/// Displays the scanned photo and detected items with their bin and confidence
/// Shows: object, bin, and confidence for each item
struct ResultsScreen: View {
    let scannedImage: UIImage
    let scanResults: [ScanItem]
    var onBack: (() -> Void)? = nil
    var onRescan: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Top header bar
            HStack {
                // Back button
                Button(action: {
                    print("DEBUG: Results back button tapped")
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
                Text("Analysis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Settings icon
                Button(action: {
                    print("DEBUG: Settings button tapped")
                    // TODO: Add settings functionality
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Scanned photo display
                    Image(uiImage: scannedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                            // Results for each item
                            if scanResults.isEmpty {
                                // No items found message
                                VStack(spacing: 12) {
                                    Text("No items found")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.gray)
                                        .padding(.top, 40)
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                // Column headers at the top
                                HStack(spacing: 12) {
                                    Text("OBJECT")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("BIN")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("CONFIDENCE")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                
                                // List of items
                                ForEach(Array(scanResults.enumerated()), id: \.element.id) { index, item in
                                    VStack(spacing: 0) {
                                        // Single bubble with all three values
                                        ZStack(alignment: .topTrailing) {
                                            // Main content bubble
                                            HStack(spacing: 12) {
                                                // Object
                                                Text(item.name)
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(.black)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                // Bin
                                                Text(item.bin)
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(.black)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                // Confidence
                                                Text(item.confidence)
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(.black)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 14)
                                            .background(Color.gray.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            // Confidence indicator bubble (corner)
                                            Circle()
                                                .fill(confidenceColor(for: item.confidence))
                                                .frame(width: 12, height: 12)
                                                .padding(8)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                    
                    // Rescan button
                    if let onRescan = onRescan {
                        Button(action: {
                            print("DEBUG: Rescan button tapped")
                            onRescan()
                        }) {
                            Text("Rescan")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .background(Color.white)
    }
    
    /// Returns color for confidence level
    private func confidenceColor(for confidence: String) -> Color {
        switch confidence.lowercased() {
        case "high":
            return Color.green
        case "medium":
            return Color.yellow
        case "low":
            return Color.red
        default:
            return Color.gray
        }
    }
}

#Preview {
    ResultsScreen(
        scannedImage: UIImage(systemName: "photo") ?? UIImage(),
        scanResults: [
            ScanItem(name: "Soda Can", bin: "Recycle", confidence: "High"),
            ScanItem(name: "Plastic Bottle", bin: "Recycle", confidence: "Medium")
        ]
    )
}

