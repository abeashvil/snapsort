//
//  SemiCircleShape.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI

/// Shape representing a semi-circle (half circle)
/// The flat edge is at the bottom, curved edge at the top
struct SemiCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create a semi-circle: arc from top-left to top-right
        // The center is at the top edge, radius equals half the width
        let center = CGPoint(x: rect.midX, y: rect.minY)
        let radius = rect.width / 2
        
        // Start from bottom-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Draw line up to the start of the arc
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // Draw arc from left (180 degrees) to right (0 degrees) - top half of circle
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Draw line down to bottom-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}

