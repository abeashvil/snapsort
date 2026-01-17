//
//  LandingPageView.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI

/// Landing Page / Home Screen - First screen users see
/// Matches the design with app title, tagline, and animated falling items
/// Includes bottom navigation bar with scan and history icons
enum HomeTab {
    case home
    case scan
    case history
}

struct LandingPageView: View {
    @State private var showCamera = false
    @Binding var capturedImage: UIImage?
    @State private var showCameraError = false
    @State private var cameraErrorMessage = ""
    @State private var showLoadingScreen = false
    @State private var showScanError = false
    @State private var scanErrorMessage = ""
    @State private var isScanning = false
    @State private var showResultsScreen = false
    @State private var scanResults: [ScanItem] = []
    @State private var scannedPhoto: UIImage?
    
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
                        
                        // Bottom navigation bar - grey rectangle with icons
                        Rectangle()
                            .fill(bottomGreyColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .overlay(
                                HStack(spacing: 0) {
                                    // Scan icon (left side)
                                    Button(action: {
                                        print("DEBUG: Scan icon tapped")
                                        selectedTab = .scan
                                        openCamera()
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(selectedTab == .scan ? .blue : .gray)
                                            
                                            Text("Scan")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(selectedTab == .scan ? .blue : .gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    
                                    // History icon (right side)
                                    Button(action: {
                                        print("DEBUG: History icon tapped")
                                        selectedTab = .history
                                        // TODO: Navigate to history screen when implemented
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: "clock.fill")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(selectedTab == .history ? .blue : .gray)
                                            
                                            Text("History")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(selectedTab == .history ? .blue : .gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 20)
                            )
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
                            selectedTab = .home // Return to home tab when camera closes
                        }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
            
            // History view placeholder (will be implemented later)
            if selectedTab == .history && !showCamera {
                HistoryPlaceholderView(
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = .home
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
        .fullScreenCover(isPresented: $showResultsScreen) {
            Group {
                if let photo = scannedPhoto {
                    ResultsScreen(
                        scannedImage: photo,
                        scanResults: scanResults,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showResultsScreen = false
                                scannedPhoto = nil
                                scanResults = []
                            }
                        },
                        onRescan: {
                            showResultsScreen = false
                            scannedPhoto = nil
                            scanResults = []
                            // Open camera again
                            openCamera()
                        }
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    // Fallback if no photo (shouldn't happen)
                    Text("No photo available")
                }
            }
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
            print("DEBUG: onChange triggered - oldValue: \(oldValue != nil ? "has image" : "nil"), newValue: \(newValue != nil ? "has image" : "nil")")
            if let image = newValue {
                print("DEBUG: Image found in onChange, isScanning: \(isScanning)")
                if !isScanning {
                    print("DEBUG: Starting scan process - showing loading screen")
                    showLoadingScreen = true
                    isScanning = true
                    print("DEBUG: Creating Task to scan photo")
                    Task {
                        print("DEBUG: Task started - about to call scanPhoto")
                        await scanPhoto(image)
                        print("DEBUG: Task completed")
                    }
                } else {
                    print("DEBUG: Already scanning, skipping")
                }
            } else {
                print("DEBUG: No image in newValue")
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
    /// Shows loading screen, runs scan, handles errors, then shows results
    private func scanPhoto(_ image: UIImage) async {
        print("DEBUG: === Starting scanPhoto function ===")
        print("DEBUG: Image size: \(image.size)")
        do {
            print("DEBUG: Calling ScanService.scanPhoto...")
            let results = try await ScanService.scanPhoto(image)
            print("DEBUG: ScanService.scanPhoto returned successfully with \(results.count) items")
            
            // Show results screen with scan results (even if empty - user should see results screen)
            await MainActor.run {
                showLoadingScreen = false
                isScanning = false
                scannedPhoto = image
                scanResults = results
                capturedImage = nil // Reset binding but keep scannedPhoto
                
                // Show results screen even if no items found
                withAnimation(.easeInOut(duration: 0.3)) {
                    showResultsScreen = true
                }
            }
        } catch {
            print("DEBUG: Scan failed with error: \(error)")
            print("DEBUG: Error type: \(type(of: error))")
            print("DEBUG: Error description: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("DEBUG: NSError domain: \(nsError.domain), code: \(nsError.code)")
                print("DEBUG: NSError userInfo: \(nsError.userInfo)")
            }
            await MainActor.run {
                isScanning = false
                showLoadingScreen = false
                if let scanError = error as? ScanError {
                    scanErrorMessage = scanError.localizedDescription
                } else {
                    scanErrorMessage = "Could not scan photo. Try again. Error: \(error.localizedDescription)"
                }
                showScanError = true
                capturedImage = nil // Reset for retry
            }
        }
    }
}
