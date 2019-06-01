//
//  GameScene.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-05-31.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, BoardObserver {
    var othelloDelegate: OthelloDelegate?
    var boardView : BoardView?
    var instructionText : SKLabelNode?
    var colorText : SKLabelNode?
    var passButton : SKLabelNode?
    var waitingForOpponent: Bool = true
    var playerState : Marker.State?
    
    func setup(delegate: OthelloDelegate, board: Board, playerState: Marker.State) {
        self.othelloDelegate = delegate
        self.playerState = playerState
        
        self.boardView = childNode(withName: "board") as? BoardView
        print("Setup board view for \(board.name)")
        self.boardView?.setup(board: board)
        
        instructionText = childNode(withName: "instructionText") as? SKLabelNode
        colorText = childNode(withName: "colorText") as? SKLabelNode
        passButton = childNode(withName: "passButton") as? SKLabelNode
        if playerState == Marker.State.White {
            colorText?.text = "Your color is: White"
        }else {
            colorText?.text = "Your color is: Black"
        }
        
        boardView?.board?.attachObserver(self)
    }
    deinit {
        boardView?.board?.detachObserver(self)
    }

    override func didMove(to view: SKView) {
        print("Moved to game scene")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if passButton!.contains(touchLocation) {
            pass()
        }else {
            placeMarker(position: touchLocation)
        }
    }
    
    func pass() {
        if waitingForOpponent {
            return
        }
        waitingForOpponent = true
        instructionText?.text = "Waiting for opponent"
        othelloDelegate?.skipPlaceMarker(playerName: boardView!.board!.name)

    }
    func placeMarker(position: CGPoint) {
        if waitingForOpponent {
            return
        }
        let cellX = Int((position.x-boardView!.position.x)/boardView!.cellSize!)
        let cellY = Int((boardView!.position.y-position.y)/boardView!.cellSize!)
        if cellX>=0 && cellX<boardView!.board!.width && cellY>=0 && cellY<boardView!.board!.height {
            if boardView!.board!.board[cellX,cellY] == nil {
                if boardView!.board!.findMarkersToChange(state: playerState!, x: cellX, y: cellY).count>0 {
                    waitingForOpponent = true
                    instructionText?.text = "Waiting for opponent"
                    othelloDelegate?.placeMarker(playerName: boardView!.board!.name, x: cellX, y: cellY, state: playerState!)
                }
            }
        }
    }
    func opponentPlaceMarker(x: Int, y: Int, state: Marker.State) {
        waitingForOpponent = false
        instructionText?.text = "Place your marker (\(playerState!))"
        boardView!.board?.addMarker(state: state, x: x, y: y)
        othelloDelegate?.placeMarkerConfirmed(playerName: boardView!.board!.name, x: x, y: y, state: state)
        checkAndProcessGameEnding()
    }

    func readyForMarkerPlacement() {
        waitingForOpponent = false
        instructionText?.text = "Place your marker (\(playerState!))"
    }

    func placeMarkerConfirmed(x: Int, y: Int, state: Marker.State) {
        boardView!.board?.addMarker(state: state, x: x, y: y)
        checkAndProcessGameEnding()
    }

    func checkAndProcessGameEnding() {
        if boardView!.board!.isAllMarkersPlaced(state: nil) {
            othelloDelegate?.gameComplete(playerName: boardView!.board!.name)
        }

    }
    
    func markerAdded(marker: Marker) {
        // TODO: Calculate game over
    }
    

    
}
