//
//  Item.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
