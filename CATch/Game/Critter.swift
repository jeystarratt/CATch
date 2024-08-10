//
//  Critter.swift
//  CATch
//
//  Created by Jey Starratt on 8/10/24.
//

import SwiftUI

/// Metadata describing an individual critter, being flung around in space.
struct Critter: Identifiable {
    /// SF Symbol-based.
    enum CritterType: String {
        case cat = "cat.fill"
        case dog = "dog.fill"
        case bird = "bird.fill"
        case teddyBear = "teddybear.fill"

        var color: Color {
            switch self {
            case .cat: .black
            case .dog: .gray
            case .bird: .green
            case .teddyBear: .blue
            }
        }
    }

    /// The ID of the critter (e.g., for animation purposes).
    let id: UUID

    /// The kind of critter.
    let type: CritterType

    /// The offset of the critter within the game space.
    var offset: CGSize

    /// The rotation of the critter at this game loop.
    var rotation: Angle

    /// The initial rotation to maintain throughout trajectory.
    let rotateRight: Bool

    /// The universal size for all critters.
    static let dimension: CGFloat = 40
}

