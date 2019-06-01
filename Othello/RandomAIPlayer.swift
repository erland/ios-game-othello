//
//  BaseAIPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-16.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

class RandomAIPlayer : Player {
    var board : Board?
    var myState : Marker.State?
    let playerName: String
    
    init(name: String) {
        playerName = name
    }
    
    struct Position {
        let x: Int
        let y: Int
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y;
        }
    }
    
    func getNextPosition() -> Position? {
        var potentialPositions : [Position] = []
        for y in 0..<board!.height {
            for x in 0..<board!.width {
                if board!.atPosition(x, y) == nil {
                    let potentialWins = board!.findMarkersToChange(state: myState!, x: x, y: y)
                    print("Found \(potentialWins.count) potential wins at position \(x),\(y)")
                    if potentialWins.count > 0 {
                        potentialPositions.append(Position(x,y))
                    }
                }
            }
        }
        if potentialPositions.count>0 {
            let selectedPos = Int.random(in: 0..<potentialPositions.count)
            return potentialPositions[selectedPos]
        }
        return nil
    }
    
    func readyToPlay(delegate: OthelloDelegate, state: Marker.State) {
        myState = state
        board = Board(name: playerName)
        delegate.readyToPlay(player: playerName,
                             state: (state == Marker.State.Black ? Marker.State.White : Marker.State.Black)
        )
    }
    
    func readyForMarkerPlacement(delegate: OthelloDelegate) {
        print("AI preparing to shoot")
        let position = getNextPosition()
        if position != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                print("AI shooting at \(position!.x),\(position!.y)")
                delegate.placeMarker(playerName: self.playerName, x: position!.x, y: position!.y, state: self.myState!)
            })
        }else {
           print("No position found for \(myState)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                print("AI can't move, skipping")
                delegate.skipPlaceMarker(playerName: self.playerName)
            })
        }
    }
    
    func placeMarkerConfirmed(delegate: OthelloDelegate, x: Int, y: Int, state: Marker.State) {
        board?.addMarker(state: state, x: x, y: y)
        if board!.isAllMarkersPlaced(state: nil) {
            delegate.gameComplete(playerName: playerName)
        }
    }
    
    func placeMarker(delegate: OthelloDelegate, x: Int, y: Int, state: Marker.State) {
        board?.addMarker(state: state, x: x, y: y)
        delegate.placeMarkerConfirmed(playerName: playerName, x: x, y: y, state: state)
    }
    func gameComplete(delegate: OthelloDelegate) {
        // Do nothing
    }
    
}
