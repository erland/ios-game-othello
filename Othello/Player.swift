//
//  Player.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol Player {
    func readyToPlay(delegate: OthelloDelegate, state: Marker.State)
    func readyForMarkerPlacement(delegate: OthelloDelegate)
    func placeMarker(delegate: OthelloDelegate, x: Int, y: Int, state: Marker.State)
    func placeMarkerConfirmed(delegate: OthelloDelegate, x: Int, y: Int, state: Marker.State)
    func gameComplete(delegate: OthelloDelegate)
}
