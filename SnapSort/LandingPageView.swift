//
//  LandingPageView.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI

/// Landing Page - First screen users see
/// Matches the design with app title, tagline, and animated falling items
/// Includes swipe gesture to proceed to camera
struct LandingPageView: View {
    @State private var showCamera = false
    @Binding var capturedImage: UIImage?
    @State private var showCameraError = false
    @State private var cameraErrorMessage = ""
    @State private var showLoadingScreen = false
    @State private var showScanError = false
    @State private var scanErrorMessage = ""
    @State private var isScanning = false
    
    // Consistent grey color for bottom area
    private var bottomGreyColor: Color {
        Color.gray.opacity(0.12)
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                ZStack {
                    // Animated falling items in background
                    // Using predetermined positions with random rotation directions and speeds
                    FallingItemView(
                        imageName: "banana",
                        startX: geometry.size.width * 0.15,
                        delay: 0.0,
                        rotationDirection: 1.0, // Clockwise
                        rotationSpeed: 3.5
                    )
                    FallingItemView(
                        imageName: "bottle",
                        startX: geometry.size.width * 0.35,
                        delay: 1.2,
                        rotationDirection: -1.0, // Counter-clockwise
                        rotationSpeed: 4.2
                    )
                    FallingItemView(
                        imageName: "banana",
                        startX: geometry.size.width * 0.65,
                        delay: 2.4,
                        rotationDirection: 1.0, // Clockwise
                        rotationSpeed: 3.8
                    )
                    FallingItemView(
                        imageName: "bottle",
                        startX: geometry.size.width * 0.85,
                        delay: 3.6,
                        rotationDirection: -1.0, // Counter-clockwise
                        rotationSpeed: 4.5
                    )
                    FallingItemView(
                        imageName: "banana",
                        startX: geometry.size.width * 0.25,
                        delay: 4.8,
                        rotationDirection: 1.0, // Clockwise
                        rotationSpeed: 3.2
                    )
                    FallingItemView(
                        imageName: "bottle",
                        startX: geometry.size.width * 0.75,
                        delay: 6.0,
                        rotationDirection: -1.0, // Counter-clockwise
                        rotationSpeed: 4.0
                    )
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // App title - centered upper middle
                        VStack(spacing: 8) {
                            Text("snapsort")
                                .font(.system(size: 56, weight: .semibold, design: .default))
                                .foregroundColor(.black)
                            
                            // Tagline
                            Text("[cool tagline here]")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 80)
                        
                        Spacer()
                        
                        // Bottom call to action area - grey rectangle
                        Rectangle()
                            .fill(bottomGreyColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .overlay(
                                Text("tap anywhere to continue")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.6))
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                openCamera()
                            }
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            
            // Camera view slides in from left when shown
            if showCamera {
                CameraView(
                    capturedImage: $capturedImage,
                    isPresented: $showCamera,
                    onBack: {
                        print("DEBUG: onBack callback called in LandingPageView")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCamera = false
                        }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showCamera)
        .sheet(isPresented: $showLoadingScreen) {
            LoadingScreen()
        }
        .alert("Camera not available", isPresented: $showCameraError) {
            Button("OK") { }
        } message: {
            Text(cameraErrorMessage)
        }
        .alert("Scan Error", isPresented: $showScanError) {
            Button("OK") {
                // Reset for retry
                capturedImage = nil
                showLoadingScreen = false
            }
        } message: {
            Text(scanErrorMessage)
        }
        .onChange(of: capturedImage) { oldValue, newValue in
            // When a photo is captured, show loading screen and start scanning
            if let image = newValue, !isScanning {
                print("DEBUG: Photo captured, starting scan process")
                showLoadingScreen = true
                isScanning = true
                Task {
                    await scanPhoto(image)
                }
            }
        }
    }
    
    /// Opens the camera screen
    private func openCamera() {
        print("DEBUG: Opening camera from landing page")
        // Check if camera is available before showing
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCamera = true
            }
        } else {
            print("DEBUG: Camera not available")
            cameraErrorMessage = "Camera not available."
            showCameraError = true
        }
    }
    
    /// Scans the captured photo (F-002)
    /// Shows loading screen, runs scan, handles errors
    private func scanPhoto(_ image: UIImage) async {
        do {
            print("DEBUG: Starting photo scan")
            let _ = try await ScanService.scanPhoto(image)
            print("DEBUG: Scan completed successfully")
            // TODO: In B-004/B-005, navigate to results screen with scan results
            // For now, just close the loading screen
            await MainActor.run {
                showLoadingScreen = false
                isScanning = false
                capturedImage = nil // Reset for next scan
            }
        } catch {
            print("DEBUG: Scan failed with error: \(error.localizedDescription)")
            await MainActor.run {
                isScanning = false
                showLoadingScreen = false
                if let scanError = error as? ScanError {
                    scanErrorMessage = scanError.localizedDescription
                } else {
                    scanErrorMessage = "Could not scan photo. Try again."
                }
                showScanError = true
                capturedImage = nil // Reset for retry
            }
        }
    }
}
