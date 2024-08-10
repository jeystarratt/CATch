//
//  Game.swift
//  CATch
//
//  Created by Jey Starratt on 8/10/24.
//

import SwiftUI
import Observation

@Observable
class Game: ObservableObject {
    /// The game area's size.
    var screenSize = CGSize(width: 10, height: 10)

    /// Whether or not the app is in the foreground.
    var isActive = true

    /// The running total for this game instance.
    var score = 0

    /// The overall list of critters that are visible.
    var critters: [Critter] = []

    /// The game's loop timer (e.g., animating the critters).
    var gameLoopTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    /// The time remaining timer (e.g., for score display).
    var timeRemainingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var timeRemaining = 0

    /// Whether or not the game is in progress.
    var started = false

    /// The basket's offset.
    var basketOffset = CGFloat.zero

    /// The basket's size.
    var basketSize: CGFloat = 10

    /// Determines the clamped position of the basket.
    var basketPosition: CGFloat {
        // To give a little more room either side.
        min(screenSize.width + 25, max(-25, basketOffset - basketSize))
    }

    /// Determines the range of the basket itself.
    var basketRange: ClosedRange<CGFloat> {
        (basketPosition...(basketPosition + basketSize))
    }


    func start() {
        critters = []
        startTimers()
        started = true
    }

    func stopTimers() {
        timeRemainingTimer.upstream.connect().cancel()
        gameLoopTimer.upstream.connect().cancel()
    }

    func startTimers() {
        gameLoopTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
        timeRemainingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timeRemaining = 60
    }

    /// Generates a random critter to be dropped from space.
    ///
    /// Top-left is (0, -height) and bottom-right is (width, 0).
    func randomCritter() -> Critter {
        // Limiting the number of cats with two levels.
        let isCat = Bool.random() ? Bool.random() : false

        // Vary the kinds of rotations.
        let rotateRight = Bool.random()

        let widthVariation = (50...Int(screenSize.width)-50).randomElement()!

        return Critter(id: UUID(),
                       type: isCat ? .cat : [.dog, .bird, .teddyBear].randomElement()!,
                       offset: CGSize(width: CGFloat(widthVariation), height: CGFloat(-screenSize.height - (Critter.dimension * 2))),
                       rotation: Angle(degrees: Double((0...360).randomElement()!)),
                       rotateRight: rotateRight)
    }

    /// Updates the time left in the game.
    func updateTime() {
        // If the game is in the foreground...
        guard isActive else { return }

        // Update our countdown, if there's time left.
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        // Otherwise, clear the board.
        else {
            started = false
            stopTimers()
        }
    }

    func next() {
        guard timeRemaining > 0 else { return }

        // Move the current critters forward.
        critters = critters.compactMap { critter in
            var copy = critter

            // If we caught a critter at the basket...
            if ((-basketSize)...0).contains(copy.offset.height) &&
                basketRange.contains(copy.offset.width) {

                // Only score for cats (naturally).
                if copy.type == .cat {
                    score += 1
                } else {
                    score = max(0, score - 1)
                }

                // Remove the caught critters.
                return nil
            }

            // Rotate the critters again and move forward.
            if critter.rotateRight {
                copy.offset = CGSize(width: critter.offset.width + 10, height: critter.offset.height + 100)
                copy.rotation = Angle(degrees: critter.rotation.degrees + 10)
            } else {
                copy.offset = CGSize(width: critter.offset.width - 10, height: critter.offset.height + 100)
                copy.rotation = Angle(degrees: critter.rotation.degrees - 10)
            }

            // Remove those that are too far gone.
            if copy.offset.height > screenSize.height {
                return nil
            }

            return copy
        }

        // Insert another critter (sometimes).
        if timeRemaining % (1...5).randomElement()! == 0 {
            critters.append(randomCritter())
        }
    }
}

