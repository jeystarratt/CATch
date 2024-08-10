//
//  MainView.swift
//  CATch
//
//  Created by Jey Starratt on 8/10/24.
//

import SwiftUI
import Observation

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase

    @State private var game = Game()

    var body: some View {
        GeometryReader { proxy in
            // -- Game Start
            ZStack {
                if game.started {
                    // -- Time Remaining
                    ZStack(alignment: .bottomTrailing) {
                        // -- Score
                        ZStack(alignment: .bottomLeading) {
                            // To take as much room as we can.
                            Color.clear

                            ForEach(game.critters) { critter in
                                Image(systemName: critter.type.rawValue)
                                    .font(Font.system(size: Critter.dimension))
                                    .foregroundStyle(critter.type.color)
                                    .rotationEffect(critter.rotation)
                                    .offset(critter.offset)
                                    .animation(.default, value: critter.offset)
                            }

                            Image(systemName: "basket.fill")
                                .font(Font.system(size: game.basketSize))
                                .foregroundStyle(.brown)
                                .offset(x: game.basketPosition)
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            game.basketOffset = gesture.location.x
                                        }
                                )
                                .padding(.bottom, 30)

                            Text(String(game.score))
                                .font(.largeTitle)
                                .offset(x: 20)
                        }

                        Text(String(game.timeRemaining))
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                            .offset(x: -20)
                    }
                }

                if game.started == false {
                    Button(action: {
                        game.start()
                    }, label: {
                        Text("Start Game")
                            .font(.title)
                    })
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            // We want the critters coming right from the top of the device.
            .ignoresSafeArea(edges: .top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(game.timeRemainingTimer) { _ in
                game.updateTime()
            }
            .onReceive(game.gameLoopTimer) { _ in
                game.next()
            }
            .onAppear {
                game.screenSize = proxy.size
                game.basketSize = proxy.size.width / 4
                game.basketOffset = proxy.size.width / 2 + (game.basketSize / 2)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                game.isActive = true
            } else {
                game.isActive = false
            }
        }
    }
}
