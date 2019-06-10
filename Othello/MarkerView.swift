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
        self.blackTexture = MarkerView.createMarkerTexture(cellSize: cellSize, color: "black", alpha: 1.0)
        self.whiteTexture = MarkerView.createMarkerTexture(cellSize: cellSize, color: "white", alpha: 1.0)
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
    
    private class func createMarkerTexture(cellSize: CGFloat, color: String, alpha: CGFloat) -> SKTexture? {
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: color), color: .black, size: CGSize(width: cellSize, height: cellSize))
        sprite.alpha = alpha
        let view = SKView(frame: CGRect(x: 0, y: 0, width: cellSize, height: cellSize))
        return view.texture(from: sprite)
    }
    
    func markerUpdated(marker: Marker) {
        let positionX = CGFloat(marker.x)*(cellSize*1.02)+cellSize/2.0-5
        let positionY = -CGFloat(marker.y)*(cellSize*1.02)-cellSize/2.0+5
        self.position = CGPoint(x: positionX, y: positionY)
        if marker.state == Marker.State.White {
            texture = whiteTexture
        }else {
            texture = blackTexture
        }
    }
    
    
}

