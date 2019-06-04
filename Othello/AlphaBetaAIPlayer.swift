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

class AlphaBetaAIPlayer : RandomAIPlayer {
    
    let depth: Int
    let delay: Double
    
    struct WeightedPosition {
        let count: Int
        let position: Position
        
        init(count: Int, position: Position) {
            self.count = count
            self.position = position
        }
    }
    
    init(name: String, depth: Int, delay: Double = 0.0) {
        self.depth = depth
        self.delay = delay
        super.init(name: name)
    }
    
    let priority: [Double] = [
        50,  -2,  10,  7,  7,  10,  -2,  50,
        -2,  -5,   0,  2,  2,   0,  -5,  -2,
        10,   0,  10,  5,  5,  10,   0,  10,
        7,   2,   5,  1,  1,   5,   2,   7,
        7,   2,   5,  1,  1,   5,   2,   7,
        10,   0,  10,  5,  5,  10,   0,  10,
        -2,  -5,   0,  2,  2,   0,  -5,  -2,
        50,  -2,  10,  7,  7,  10,  -2,  50
    ]
    
    override func thinkTime() -> Double {
        return delay
    }

    override func getNextPosition() -> Position? {
        let potentialPositions = findPotentialPositions(board: board!, state: myState!)
        
        var bestScore = -Double.infinity
        var bestPosition : Position?
        for pos in potentialPositions {
            let copyOfBoard = Board(name: board!.name, board: board!.board.copy() as! Array2D<Marker>)
            copyOfBoard.addMarker(state: myState!, x: pos.x, y: pos.y)
            print("Evaluating \(myState!) at \(pos.x),\(pos.y)")
            let score = minMax(board: copyOfBoard, depth: 0, isMax: false, alpha: -Double.infinity, beta: Double.infinity)
            if score > bestScore {
                bestScore = score
                bestPosition = pos
            }
        }
        return bestPosition
        
    }

    func minMax(board: Board, depth: Int, isMax: Bool, alpha: Double, beta: Double) -> Double {
        let opponentState = (myState == Marker.State.White ? Marker.State.Black : Marker.State.White)
        if depth>self.depth || board.isAllMarkersPlaced(state: nil) {
            let result = evaluateBoard(board: board, state: myState!)
            //print ("Got \(result) with board:")
            board.debugBoard()
            return result
        }
        
        if isMax {
            let possiblePositions = findPotentialPositions(board: board, state: myState!)
            if possiblePositions.count > 0 {
                var best = -Double.infinity
                var alphaScore = alpha
                for pos in possiblePositions {
                    if depth == 0 {
                        print("Evaluating \(myState!) at \(pos.x),\(pos.y)")
                    }
                    let copyOfBoard = Board(name: board.name, board: board.board.copy() as! Array2D<Marker>)
                    copyOfBoard.addMarker(state: myState!, x: pos.x, y: pos.y)
                    let minMaxScore = minMax(board: copyOfBoard, depth: depth+1, isMax: !isMax, alpha: alphaScore, beta: beta)
                    best = max(best, minMaxScore)
                    alphaScore = max(alphaScore, best)
                    if beta<=alphaScore {
                        break
                    }
                }
                return best
            }else {
                return 0
            }
        }else {
            //board.debugBoard(debug: true)
            let possiblePositions = findPotentialPositions(board: board, state: opponentState)
            if possiblePositions.count > 0 {
                var best = Double.infinity
                var betaScore = beta
                for pos in possiblePositions {
                    if depth == 0 {
                        print("Evaluating \(opponentState) at \(pos.x),\(pos.y)")
                    }
                    let copyOfBoard = Board(name: board.name, board: board.board.copy() as! Array2D<Marker>)
                    copyOfBoard.addMarker(state: opponentState, x: pos.x, y: pos.y)
                    let minMaxScore = minMax(board: copyOfBoard, depth: depth+1, isMax: !isMax, alpha: alpha, beta: betaScore)
                    best = min(best, minMaxScore)
                    betaScore = min(betaScore, best)
                    if betaScore<=alpha {
                        break
                    }
                }
                return best
            }else {
                return 0
            }
        }
        
    }
    
    func boardAsString(board: Board) -> String {
        var white = ""
        var black = ""
        for y in 0..<board.height {
            for x in 0..<board.width {
                let cell = board.atPosition(x,y)
                if cell == nil {
                    white = white + "_"
                    black = black + "_"
                }else if cell!.state == Marker.State.White {
                    white = white + "1"
                    black = black + "_"
                }else {
                    white = white + "_"
                    black = black + "1"
                }
            }
        }
        return white+black
    }
    
    func evaluateBoard(board: Board, state: Marker.State) -> Double {
        var count = 0.0
        for y in 0..<board.height {
            for x in 0..<board.width {
                if let m = board.atPosition(x, y) {
                    if m.state == state {
                        count = count + priority[y*x]
                    }else {
                        count = count - priority[y*x]
                    }
                }
            }
        }
        return count/64.0
    }
    
    func findPotentialPositions(board: Board, state: Marker.State) -> [Position] {
        var potentialPositions : [WeightedPosition] = []
        for y in 0..<board.height {
            for x in 0..<board.width {
                if board.atPosition(x, y) == nil {
                    let potentialWins = board.findMarkersToChange(state: state, x: x, y: y)
                    if potentialWins.count > 0 {
                        let pos = WeightedPosition(count: potentialWins.count, position: Position(x,y))
                        potentialPositions.append(pos)
                    }
                }
            }
        }
        potentialPositions  = potentialPositions.sorted(by: {$0.count>$1.count})
        var result : [Position] = []
        for pos in potentialPositions {
            result.append(pos.position)
        }
        return result
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
