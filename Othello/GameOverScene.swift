//
//  GameOverScene.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    var othelloDelegate: OthelloDelegate?
    var boardView: BoardView?
    var playerState: Marker.State?
    var openedTime: TimeInterval?
    
    func setup(delegate: OthelloDelegate, board: Board, playerState: Marker.State) {
        self.othelloDelegate = delegate
        self.playerState = playerState
        
        self.boardView = childNode(withName:"board") as? BoardView
        self.boardView?.setup(board: board)
    }
    
    override func didMove(to view: SKView) {
        let winnerText = childNode(withName: "winnerText") as? SKLabelNode
        openedTime = NSDate().timeIntervalSince1970
        let opponentState = (playerState == Marker.State.White ? Marker.State.Black : Marker.State.White)
        let myMarkers = boardView!.board!.noOfMarkers(with: playerState!)
        let opponentMarkers = boardView!.board!.noOfMarkers(with: opponentState)
        if myMarkers>opponentMarkers {
            winnerText?.text = "You won! (\(myMarkers) - \(opponentMarkers))"
        }else if myMarkers==opponentMarkers {
            winnerText?.text = "It's a draw"
        }else {
            winnerText?.text = "You lost (\(myMarkers) - \(opponentMarkers))"
        }

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // We need to ensure the sceen is shown for 2 seconds before we allow player to continue
        if openedTime!<NSDate().timeIntervalSince1970-2 {
            othelloDelegate?.finishedGame()
        }
    }
}
