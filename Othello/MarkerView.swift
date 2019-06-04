//
//  ShipView.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class MarkerView : SKSpriteNode, MarkerObserver {
    let cellSize: CGFloat
    let blackTexture: SKTexture?
    let whiteTexture: SKTexture?
    let marker : Marker
    
    init(marker: Marker, cellSize: CGFloat) {
        self.cellSize = cellSize
        self.marker = marker
        self.blackTexture = MarkerView.createMarkerTexture(cellSize: cellSize, borderColor: UIColor.black, fillColor: UIColor.black, alpha: 1.0)
        self.whiteTexture = MarkerView.createMarkerTexture(cellSize: cellSize, borderColor: UIColor.white, fillColor: UIColor.white, alpha: 1.0)
        var texture = blackTexture
        if marker.state == Marker.State.White {
            texture = whiteTexture
        }
        super.init(texture: texture, color: UIColor.black, size: CGSize(width: cellSize, height: cellSize))
        marker.attachObserver(observer: self)
        anchorPoint = CGPoint(x: 0, y: 1)
        markerUpdated(marker: marker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func createMarkerTexture(cellSize: CGFloat, borderColor: UIColor, fillColor: UIColor, alpha: CGFloat) -> SKTexture? {
        let shape = SKShapeNode.init(ellipseOf: CGSize(width: cellSize,
                                                    height: cellSize))
        shape.fillColor = fillColor
        shape.strokeColor = borderColor
        shape.alpha = alpha
        let view = SKView(frame: CGRect(x: 0, y: 0, width: cellSize, height: cellSize))
        return view.texture(from: shape)
    }
    
    func markerUpdated(marker: Marker) {
        let positionX = CGFloat(marker.x)*cellSize+cellSize/2.0
        let positionY = -CGFloat(marker.y)*cellSize-cellSize/2.0
        self.position = CGPoint(x: positionX, y: positionY)
        let flip = SKAction.scaleX(to: -1, duration: 0.2)
        if marker.state == Marker.State.White {
            if texture == blackTexture {
                let changeTexture = SKAction.run({ self.texture = self.whiteTexture})
                let action = SKAction.sequence([flip, changeTexture])
                run(action)
            }else {
                texture = whiteTexture
            }
        }else {
            if texture == whiteTexture {
                let changeTexture = SKAction.run({ self.texture = self.blackTexture})
                let action = SKAction.sequence([flip, changeTexture])
                run(action)
            }else {
                texture = blackTexture
            }
        }
    }
    
    
}

