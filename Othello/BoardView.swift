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
    var showShootMarking: Bool = false
    var lastShootMarking : SKShapeNode?
    
    func setup(board: Board, showShootMarking: Bool = false) {
        self.cellSize = size.width/CGFloat(board.width)
        print("\(size.width) with \(board.width) gives cellSize=\(cellSize!)")
        self.board = board
        self.scale = cellSize!/50.0
        self.showShootMarking = showShootMarking
        let gridTexture = BoardView.createBoardGridTexture(x: board.width, y: board.height, cellSize: cellSize!)
        
        let gridSprite = SKSpriteNode(texture: gridTexture)
        gridSprite.anchorPoint = CGPoint(x: 0.0,y: 1.0)
        gridSprite.position = CGPoint(x: -1.0, y: 1.0)
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
        let border = SKShapeNode.init(rectOf: CGSize(width: boardWidth,
                                                     height: boardHeight))
        border.strokeColor = UIColor.white
        
        for row in 1..<(y) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: 0.0, y: CGFloat(row)*cellSize),
                                            to: CGPoint(x: boardWidth, y: CGFloat(row)*cellSize))
            line.strokeColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
            border.addChild(line)
        }
        for column in 1..<(x) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: CGFloat(column)*cellSize, y: 0),
                                            to: CGPoint(x: CGFloat(column)*cellSize, y: boardHeight))
            line.strokeColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
            border.addChild(line)
        }
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight))
        return view.texture(from: border)
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
    }
    
    private func updateLastShootMarking(x: Int, y: Int, hit: Bool) {
        if showShootMarking {
            if let lastShootMarking = self.lastShootMarking {
                lastShootMarking.removeFromParent()
            }
            lastShootMarking = SKShapeNode.init(rectOf: CGSize(width: cellSize!, height: cellSize!))
            lastShootMarking?.position = CGPoint(x: CGFloat(x)*cellSize!+cellSize!/2, y: -CGFloat(y)*cellSize!-cellSize!/2)
            lastShootMarking?.zPosition=15
            if hit {
                lastShootMarking?.strokeColor = UIColor.yellow
                lastShootMarking?.lineWidth = 2.0
            }else {
                lastShootMarking?.strokeColor = UIColor.white
            }
            lastShootMarking?.run(
                SKAction.repeat(
                    SKAction.sequence([
                        SKAction.fadeIn(withDuration: 0.1),
                        SKAction.fadeOut(withDuration: 0.1)]),
                    count: 20))
            addChild(lastShootMarking!)
        }
    }
    
    func shootAt(x: Int, y: Int, hit: Bool) {
        updateLastShootMarking(x: x, y: y, hit: hit)
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

