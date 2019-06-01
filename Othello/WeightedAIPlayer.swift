//
//  WeightedAIPlayer.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-06-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

//
//  MostWinsAIPlayer.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-06-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

class WeightedAIPlayer : RandomAIPlayer {
    
    struct WeightedPosition {
        let count: Int
        let position: Position
        
        init(count: Int, position: Position) {
            self.count = count
            self.position = position
        }
    }
    override func getNextPosition() -> Position? {
        var potentialPositions : [WeightedPosition] = []
        var safePositions : [WeightedPosition] = []
        var cornerPositions : [WeightedPosition] = []
        for y in 0..<board!.height {
            for x in 0..<board!.width {
                if board!.atPosition(x, y) == nil {
                    let potentialWins = board!.findMarkersToChange(state: myState!, x: x, y: y)
                    print("Found \(potentialWins.count) potential wins at position \(x),\(y)")
                    if potentialWins.count > 0 {
                        let pos = WeightedPosition(count: potentialWins.count,position: Position(x,y))
                        potentialPositions.append(pos)
                        if (x==0 && y==0) || (x==7 && y==0) || (x==0 && y==7) || (x==7&&y==7) {
                            cornerPositions.append(pos)
                        }
                        if (x<2 && y<2) || (x>5 && y<2) || (x<2 && y>5) || (x>5 && y>5) {
                            // Do nothing
                        }else {
                            safePositions.append(pos)
                        }
                    }
                }
            }
        }
        if cornerPositions.count>0 {
            return bestPosition(potentialPos: cornerPositions)
        }
        if safePositions.count>0 {
            return bestPosition(potentialPos: safePositions)
        }
        if potentialPositions.count>0 {
            return bestPosition(potentialPos: potentialPositions)
        }
        return nil
    }
    
    func bestPosition(potentialPos: [WeightedPosition]) -> Position {
        var maxCount = 0
        var selectedPotentialPos: [Position] = []
        for pos in potentialPos {
            if pos.count==maxCount {
                selectedPotentialPos = selectedPotentialPos + [pos.position]
            }else if pos.count>maxCount {
                maxCount = pos.count
                selectedPotentialPos = [pos.position]
            }
        }
        let selectedPos = Int.random(in: 0..<selectedPotentialPos.count)
        return selectedPotentialPos[selectedPos]
    }
    
}
