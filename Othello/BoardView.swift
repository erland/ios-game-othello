//
//  BoardView.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BoardView : SKSpriteNode, BoardObserver {
    
    var board: Board?
    var cellSize: CGFloat?
    var scale: CGFloat?
    var lastMarker : SKShapeNode?
    var lastMarkersChanged : [SKShapeNode] = []

    func setup(board: Board) {
        self.cellSize = size.width/CGFloat(board.width)
        print("\(size.width) with \(board.width) gives cellSize=\(cellSize!)")
        self.board = board
        self.scale = cellSize!/50.0
        let gridTexture = BoardView.createBoardGridTexture(x: board.width, y: board.height, cellSize: cellSize!)
        
        let gridSprite = SKSpriteNode(texture: gridTexture)
        gridSprite.anchorPoint = CGPoint(x: 0.0,y: 1.0)
        gridSprite.position = CGPoint(x: -25.0, y: 24.0)
        addChild(gridSprite)

        /*
        for y in 0..<board.height {
            for x in 0..<board.width {
                if board.shoots[x,y] != nil {
                    shootAt(x: x, y: y, hit: board.shoots[x,y]!)
                }
            }
        }
        */
        board.attachObserver(self)
    }
    
    private class func createBoardGridTexture(x: Int, y: Int, cellSize: CGFloat) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize
        
        let board = SKSpriteNode(texture: SKTexture(imageNamed: "board"),
                                 color: .black,
                                 size: CGSize(width: boardWidth+50, height: boardHeight+50))
        
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth+50, height: boardHeight+50))
        return view.texture(from: board)
    }
    
    private class func createLine(anchor: CGPoint, from:CGPoint, to: CGPoint) -> SKShapeNode {
        let lineShape = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: anchor.x+from.x, y: anchor.y+from.y))
        path.addLine(to: CGPoint(x: anchor.x+to.x, y: anchor.y+to.y))
        lineShape.path = path
        return lineShape
    }
    
    func markerAdded(marker: Marker) {
        let markerView = MarkerView(marker: marker, cellSize: cellSize!)
        markerView.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        markerView.name = "marker"
        markerView.zPosition = 10
        addChild(markerView)
        updateLastMarker(x: marker.x, y: marker.y, state: marker.state)
    }
    
    private func updateLastMarker(x: Int, y: Int, state: Marker.State) {
        if board!.markers.count>4 {
            if let lastMarker = self.lastMarker {
                lastMarker.removeFromParent()
            }
            lastMarker = SKShapeNode.init(rectOf: CGSize(width: cellSize!, height: cellSize!))
            lastMarker?.position = CGPoint(x: CGFloat(x)*(cellSize!*1.02)+cellSize!/2-5, y: -CGFloat(y)*(cellSize!*1.02)-cellSize!/2+5)
            lastMarker?.zPosition=15
            if state == Marker.State.White {
                lastMarker?.strokeColor = UIColor.yellow
            }else {
                lastMarker?.strokeColor = UIColor.red
            }
            lastMarker?.lineWidth = 2.0
            lastMarker?.run(
                    SKAction.fadeOut(withDuration: 1.0))
            addChild(lastMarker!)
        }
    }
    
    func viewForMarker(marker: Marker) -> MarkerView? {
        var result: MarkerView?
        enumerateChildNodes(withName: "marker") {
            (node, stop) in
            if node is MarkerView {
                let markerView  = node as! MarkerView
                if markerView.marker === marker {
                    result = markerView
                }
            }
        }
        return result
    }
}

