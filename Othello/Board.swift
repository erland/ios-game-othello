//
//  Board.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-29.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BoardObserver : class {
    func markerAdded(marker: Marker)
}
class Board {
    let name: String
    let width: Int = 8
    let height: Int = 8
    let board: Array2D<Marker>
    var markers: Set<Marker> = Set()
    var observers: [BoardObserver] = []
    
    init(name: String) {
        self.name = name
        self.board = Array2D<Marker>(columns: width, rows: height)
        markers.insert(initMarker(state: Marker.State.Black, x: 3, y: 3))
        markers.insert(initMarker(state: Marker.State.White, x: 4, y: 3))
        markers.insert(initMarker(state: Marker.State.White, x: 3, y: 4))
        markers.insert(initMarker(state: Marker.State.Black, x: 4, y: 4))
    }
    private func initMarker(state: Marker.State, x: Int, y: Int) -> Marker {
        let m = Marker(state: state)
        m.x = x
        m.y = y
        board[x,y] = m
        for observer in observers {
            observer.markerAdded(marker: m)
        }
        return m
    }
    func attachObserver(_ observer: BoardObserver) {
        for marker in markers {
            observer.markerAdded(marker: marker)
        }
        observers.append(observer)
    }
    
    func detachObserver(_ observer: BoardObserver) {
        if let index = (self.observers.firstIndex(where: { $0 === observer })) {
            self.observers.remove(at: index)
        }
    }
    
    func atPosition(_ x: Int, _ y: Int) -> Marker? {
        if x>=0 && x<width && y>=0 && y<height {
            return board[x, y]
        }else {
            return nil
        }
    }
    
    func addMarker(state: Marker.State, x: Int, y: Int) {
        print("Board(\(name)): Trying to add \(state) at: \(x),\(y)")
        if x<0 || x >= width {
            // Outside board
            print("Outside board")
            return
        }
        if y<0 || y>=height {
            // Outside board
            print("Outside board")
            return
        }
        if board[x,y] != nil {
            // Already occupied
            print("Already occupied")
            return
        }
        let markersToChange = findMarkersToChange(state: state, x: x, y: y)
        print("Found \(markersToChange.count) markers to change if placed at: \(x),\(y)")

        if markersToChange.count == 0 {
            // No markers to change found, at least one needs to change for this to be an allowed position
            return
        }
        for marker in markersToChange {
            marker.state = state
        }
        let m = Marker(state: state)
        m.x = x
        m.y = y
        board[x,y] = m
        markers.insert(m)
        for observer in observers {
            observer.markerAdded(marker: m)
        }
        print("Board(\(name)): Added \(state) at: \(x),\(y)")
        debugBoard()
    }
    
    func findMarkersToChange(state: Marker.State, x: Int, y: Int) -> [Marker] {
        var markersToChange : [Marker] = []
        let reversedState = (state==Marker.State.Black ? Marker.State.White : Marker.State.Black)
        
        if x>1 && board[x-1,y] != nil && board[x-1,y]!.state == reversedState {
            let markers = findInDirection(state: state, x: x,  y: y, offsetX: -1, offsetY: 0)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }
        if x<width-2 && board[x+1,y] != nil && board[x+1,y]!.state == reversedState {
            let markers = findInDirection(state: state, x: x, y: y, offsetX: 1, offsetY: 0)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }
        if y>1 && board[x,y-1] != nil && board[x,y-1]!.state == reversedState {
            let markers = findInDirection(state: state, x: x, y: y, offsetX: 0, offsetY: -1)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }
        if y<height-2 && board[x,y+1] != nil && board[x,y+1]!.state == reversedState {
            let markers = findInDirection(state: state, x: x, y: y, offsetX: 0, offsetY: 1)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }
        
        if x>1 && y>1 && board[x-1,y-1] != nil && board[x-1,y-1]!.state == reversedState {
            let markers = findInDirection(state: state, x: x,  y: y, offsetX: -1, offsetY: -1)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }
        if x<width-2 && y>1 && board[x+1,y-1] != nil && board[x+1,y-1]!.state == reversedState {
            let markers = findInDirection(state: state, x: x, y: y, offsetX: 1, offsetY: -1)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }
        if x<width-2 && y<height-2 && board[x+1,y+1] != nil && board[x+1,y+1]!.state == reversedState {
            let markers = findInDirection(state: state, x: x, y: y, offsetX: 1, offsetY: 1)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }
        if x>1 && y<height-2 && board[x-1,y+1] != nil && board[x-1,y+1]!.state == reversedState {
            let markers = findInDirection(state: state, x: x, y: y, offsetX: -1, offsetY: 1)
            if markers != nil && markers!.count>0 {
                markersToChange = markersToChange + markers!
            }
        }

        return markersToChange
    }
    
    private func findInDirection(state: Marker.State, x: Int, y: Int, offsetX: Int, offsetY: Int) -> [Marker]? {
        if x+offsetX < 0 || x+offsetX >= width || y+offsetY < 0 || y+offsetY >= height {
            // Reached end of board
            return nil
        }
        if board[x+offsetX,y+offsetY] == nil {
            // Reached empty position
            return nil
        }else if board[x+offsetX,y+offsetY]!.state == state {
            // Found marker with matching state
            return []
        }else {
            // Reversed marker, keep searching
            var result = [board[x+offsetX,y+offsetY]!]
            print("Found potential win at: \(x+offsetX),\(y+offsetY)")
            let markers = findInDirection(state:state, x:x+offsetX, y:y+offsetY, offsetX:offsetX, offsetY:offsetY)
            if markers != nil {
                return result + markers!
            }else {
                return nil
            }
        }
    }
    
    func isAllMarkersPlaced(state: Marker.State?) -> Bool {
        var result = true
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] == nil {
                    result = false
                    break
                }
            }
            if !result {
                break
            }
        }
        if !result {
            for y in 0..<height {
                for x in 0..<width {
                    if board[x,y] == nil {
                        let whiteMarkers = findMarkersToChange(state: Marker.State.White, x: x, y: y)
                        if whiteMarkers.count == 0 {
                            let blackMarkers = findMarkersToChange(state: Marker.State.Black, x: x, y: y)
                            if blackMarkers.count > 0 {
                                return false
                            }
                        }else {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    func noOfMarkers(with state: Marker.State) -> Int {
        var count = 0
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] != nil && board[x,y]!.state == state {
                    count = count + 1
                }
            }
        }
        return count
    }
    
    func debugBoard() {
        print("Board contents")
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] != nil {
                    if board[x,y]?.state == Marker.State.Black {
                        print("X", terminator: "")
                    }else {
                        print("O", terminator: "")
                    }
                }else {
                    print("_", terminator: "")
                }
            }
            print()
        }
    }
    
}
