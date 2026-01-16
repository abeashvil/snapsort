//
//  FallingItemView.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI

/// Animated falling item view
/// Displays an image that falls down the screen while rotating
/// Acceleration increases over time for natural motion
struct FallingItemView: View {
    let imageName: String
    let startX: CGFloat
    let delay: Double
    let rotationDirection: Double // 1.0 for clockwise, -1.0 for counter-clockwise
    let rotationSpeed: Double // Duration for one full rotation
    
    @State private var yPosition: CGFloat = -100
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 140, height: 140)
            .opacity(0.5) // More visible - increased from 0.3
            .rotationEffect(.degrees(rotation))
            .position(x: startX, y: yPosition)
            .onAppear {
                let screenHeight = UIScreen.main.bounds.height
                startFalling(screenHeight: screenHeight)
            }
    }
    
    /// Starts the falling animation with rotation and acceleration
    private func startFalling(screenHeight: CGFloat) {
        // Start rotation animation with random direction and speed
        withAnimation(.linear(duration: rotationSpeed).repeatForever(autoreverses: false)) {
            rotation = 360 * rotationDirection
        }
        
        // Start falling after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            fallWithAcceleration(screenHeight: screenHeight)
        }
    }
    
    /// Falls with acceleration (starts slow, speeds up) - smooth continuous motion
    private func fallWithAcceleration(screenHeight: CGFloat) {
        let totalDistance = screenHeight + 200
        
        // Single smooth animation with easeIn for natural acceleration
        // Reduced duration for faster acceleration (was 9.0, now 6.5)
        withAnimation(.easeIn(duration: 6.5)) {
            yPosition = totalDistance
        }
        
        // Reset and repeat after reaching bottom
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            yPosition = -100
            // Small random delay before next fall
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...1.5)) {
                fallWithAcceleration(screenHeight: screenHeight)
            }
        }
    }
}

