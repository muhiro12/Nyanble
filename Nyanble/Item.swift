//
//  Item.swift
//  Nyanble
//
//  Created by Hiromu Nakano on 2025/06/14.
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
