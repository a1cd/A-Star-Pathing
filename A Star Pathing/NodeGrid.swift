//
//  NodeGrid.swift
//  A Star Pathing
//
//  Created by Everett Wilber on 4/17/21.
//

import Foundation
import SpriteKit
import GameplayKit

enum Direction {
	case N
	case E
	case S
	case W
}
let Directions: [Direction: CGPoint] = [
	.N: .init(0,1),
	.E: .init(1,0),
	.S: .init(0,-1),
	.W: .init(-1,0)
]
extension Direction {
	func apply(to: CGPoint) -> CGPoint {
		return to + Directions[self]!
	}
}
struct NodeGrid {
	var width: UInt
	var height: UInt
	var nodes: [Node] = []
	var explorable: [Node] = []
	init<type: BinaryInteger>(width: type, height: type) {
		for x in 0..<UInt(width) {
			for y in 0..<UInt(height) {
				nodes.append(Node(.Default))
			}
		}
		self.width = UInt(width)
		self.height = UInt(height)
	}
	func get(_ x: CGPoint) -> Node {
		return nodes[Int((Int(x.x)*Int(width))+Int(x.y))]
	}
	mutating func set(_ x: CGPoint, _ newvalue: Node) {
		nodes[(Int(x.x)*Int(width))+Int(x.y)] = newvalue
	}
	subscript (_ x: Int, _ y: Int) -> Node{
		get {
			return get(CGPoint(x: x, y: y))
		}
		set {
			set(CGPoint(x: x, y: y), newValue)
		}
	}
	subscript (_ x: CGPoint) -> Node{
		get {
			return get(x)
		}
		set {
			set(x, newValue)
		}
	}
	func findStart() -> CGPoint{
		return CGPoint.zero
	}
	func findGoal() -> CGPoint {
		return CGPoint.zero
	}
	mutating func exploreSurrounding(from: CGPoint) {
		for (dir, _) in Directions {
			let exploringPoint = dir.apply(to: from)
			if !self[exploringPoint].Explored {
				if self[exploringPoint].Property == .Default {
					self[exploringPoint].Explored = true
					
				}
			}
		}
	}
	mutating func solve() {
		explorable.removeAll()
		let Start = findStart()
		let Goal = findGoal()
		
	}
}
struct Node {
	var Property: NodeProperty
	var Explored = false
	init(_ Property: NodeProperty) {
		self.Property = Property
	}
}
enum NodeProperty {
	case Default
	case Wall
	case Water
	case Start
	case End
}
extension NodeProperty {
	var Color: NSColor {
		let ColorTable: [NodeProperty: NSColor] = [
			.Default: .gray,
			.Water: .blue,
			.Wall: .red,
			.Start: .purple,
			.End: .yellow
		]
		for (Property, Color) in ColorTable {
			if self == Property {
				return Color
			}
		}
		return .orange
	}
}
