//
//  MostWinsAIPlayer.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-06-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

class MostWinsAIPlayer : RandomAIPlayer {
    
    override func getNextPosition() -> Position? {
        var potentialPositions : [Position] = []
        var maxPotentialWins = 0
        for y in 0..<board!.height {
            for x in 0..<board!.width {
                if board!.atPosition(x, y) == nil {
                    let potentialWins = board!.findMarkersToChange(state: myState!, x: x, y: y)
                    print("Found \(potentialWins.count) potential wins at position \(x),\(y)")
                    if potentialWins.count > 0 && potentialWins.count>=maxPotentialWins {
                        potentialPositions.append(Position(x,y))
                        maxPotentialWins = potentialWins.count
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

}
