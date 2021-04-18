//
//  NodeGrid.swift
//  A Star Pathing
//
//  Created by Everett Wilber on 4/17/21.
//

import Foundation
import SpriteKit
import GameplayKit
import Accelerate

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
	private var updateable = false
	var width: UInt
	var height: UInt
	var nodes: [Node] = []
	var explorable: [CGPoint] = []
	var goal: CGPoint = CGPoint.zero
	var start: CGPoint = CGPoint.zero
	init<type: BinaryInteger>(width: type, height: type) {
		for x in 0..<UInt(width) {
			for y in 0..<UInt(height) {
				nodes.append(Node(.Default))
			}
		}
		self.width = UInt(width)
		self.height = UInt(height)
	}
	func toId(from: CGPoint) -> Int {
		return (Int(from.x) * Int(width)) + Int(from.y)
	}
	func flip(x: UInt) -> Int {
		let valuething = (Int(width-1)/2)
		return (-(Int(x)-valuething))+valuething
	}
	func flip(y: UInt) ->  Int {
		let valuething = (Int(height-1)/2)
		return (-(Int(y)-valuething))+valuething
	}
	func debug() -> String {
		var grid: [[Int]] = []
		for x in 0..<width-1 {
			grid.append([])
			for y in 0..<height-1 {
				var appender = 0
				if self[flip(x: x), flip(y: y)].Property == .End {
					appender = 2
				} else if self[flip(x: x), flip(y: y)].Property == .Start {
					appender = 3
				} else if self[flip(x: x), flip(y: y)].Explored {
					appender = 1
				} else if explorable.contains(CGPoint(x: flip(x: x), y: flip(y: y))){
					appender = 4
				} else {
					appender = 0
				}
				grid[Int(x)].append(appender)
			}
		}
		var printer = " "
		for i in 0..<width {
			printer.append(" "+String(i))
		}
		printer.append("\n")
		for (i, row) in grid.enumerated() {
			printer.append(String(i))
			for column in row {
				printer.append(" ")
				if column == 1 {
					printer.append("O")
				} else if column == 0 {
					printer.append("·")
				} else if column == 2 {
					printer.append("@")
				} else if column == 3 {
					printer.append("S")
				} else {
					printer.append("*")
				}
				
			}
			printer.append("\n")
		}
		return printer
	}
	func get(_ x: CGPoint) -> Node {
		let widthAdders = Int(x.x)*Int(width)
		return nodes[widthAdders+Int(x.y)]
	}
	mutating func set(_ x: CGPoint, _ newvalue: Node) {
		nodes[(Int(x.x)*Int(width))+Int(x.y)] = newvalue
	}
	subscript <type: BinaryInteger>(_ x: type, _ y: type) -> Node{
		get {
			return get(CGPoint(x: Int(x), y: Int(y)))
		}
		set {
			set(CGPoint(x: Int(x), y: Int(y)), newValue)
		}
	}
	subscript (_ x: CGPoint) -> Node? {
		get {
			if x.x > 0 && x.x < CGFloat(width) && x.y > 0 && x.y < CGFloat(height) {
				return get(x)
			} else {
				return nil
			}
		}
		set {
			set(x, newValue!)
		}
	}
	func validate(_ point: CGPoint) -> Bool {
		if point.x > 0 && point.x < CGFloat(width) && point.y > 0 && point.y < CGFloat(height) {
			return true
		}
		return false
	}
	func findStart() -> CGPoint{
		for x in 0..<width {
			for y in 0..<height {
				let point = get(CGPoint(x: Int(x), y: Int(y)))
				if point.Property == .Start {
					return CGPoint(x: Int(x), y: Int(y))
				}
			}
		}
		return CGPoint.zero
	}
	func findGoal() -> CGPoint {
		for x in 0..<width {
			for y in 0..<height {
				let point = get(CGPoint(x: Int(x), y: Int(y)))
				if point.Property == .End {
					return CGPoint(x: Int(x), y: Int(y))
				}
			}
		}
		return CGPoint.zero
	}
	mutating func CostCalc(_ x: CGPoint) {
		let goalDist = vDSP.distanceSquared([Float(x.x), Float(x.y)], [Float(goal.x), Float(goal.y)])
		self[x]?.distToGoal = CGFloat(goalDist)
		self[x]?.cost = CGFloat(goalDist)
	}
	mutating func exploreSurrounding(from: CGPoint) -> Bool {
		if let index = explorable.firstIndex(of: from) {
			explorable.remove(at: index)
		}
		let baseCost = (self[from]?.cost, self[from]?.distFromStart, self[from]?.distToGoal)
		let thread = DispatchQueue.global(qos: .userInteractive)
		let group = DispatchGroup()
		var foundEnd = false
		var appends: [CGPoint] = []
		for (dir, _) in Directions {
			let exploringPoint = dir.apply(to: from)
			if validate(exploringPoint) {
				let savedExploringPoint = self[exploringPoint]
				self.updateable.toggle()
				if !savedExploringPoint!.Explored {
					if savedExploringPoint!.Property == .Default {
						appends.append(exploringPoint)
						self.CostCalc(exploringPoint)
						self[exploringPoint]!.cost = baseCost.2! + (self[exploringPoint]?.distToGoal)!
						self[exploringPoint]?.parent = from
					} else if savedExploringPoint!.Property == .End {
						self[exploringPoint]?.parent = from
						foundEnd = true
					}
				}
			}
		}
		group.wait()
		explorable.append(contentsOf: appends)
		return foundEnd
	}
	mutating func explore(Goal: CGPoint, Start: CGPoint) -> Bool{
		self[Start]!.Explored = true
//		for unexploredPoint in explorable {
//			let goalDistSqared = vDSP.distanceSquared([Float(unexploredPoint.x), Float(unexploredPoint.y)], [Float(Goal.x), Float(Goal.y)])
//			let goalDist = CGFloat(sqrt(goalDistSqared))
//			let startDistSqared = vDSP.distanceSquared([Float(unexploredPoint.x), Float(unexploredPoint.y)], [Float(Start.x), Float(Start.y)])
//			let startDist = CGFloat(sqrt(startDistSqared))
//			self[unexploredPoint]!.cost = goalDist + (startDist/2)
//
//		}
		var explorableMin: CGPoint = CGPoint.zero
		if explorable.count != 0 {
			explorableMin = explorable[0]
		} else {
			return true
		}
		var expNum: Int? = nil
		for (num, i) in explorable.enumerated() {
			if !self[i]!.Explored {
				if get(explorableMin).cost! > get(i).cost! {
					explorableMin = i
					expNum = num
				}
			}
		}
//		print(explorableMin.x, explorableMin.y)
		
		self[explorableMin]!.Explored = true
		
		
		if expNum != nil {
			explorable.remove(at: expNum!)
		}
		let results = exploreSurrounding(from: explorableMin)
//		print(debug())
		return results
		
	}
	var parentTrain: [CGPoint] = [CGPoint.zero, CGPoint.zero]
	mutating func trace() -> [CGPoint] {
		parentTrain = []
		parentTrain.append(self[goal]!.parent!)
		var traceCount = 0
		while true {
			traceCount += 1
			let newMainNode: CGPoint = parentTrain[parentTrain.count-1]
			if self[newMainNode]!.Property != .Start {
				parentTrain.append(self[newMainNode]!.parent!)
			} else {
				break
			}
			if traceCount > (width*height)/2 {
				break
			}
		}
		return parentTrain
	}
	mutating func path(multiplier: CGPoint) -> CGMutablePath {
		solve()
		var Path = CGMutablePath()
		Path.move(to: parentTrain[0]*multiplier)
		for i in 1..<parentTrain.count {
			Path.addLine(to: parentTrain[i]*multiplier)
		}
		return Path
	}
	mutating func solve() {
		explorable.removeAll()
		for (i, val) in nodes.enumerated() {
			nodes[i].Explored = false
			nodes[i].cost = nil
		}
		start = findStart()
		goal = findGoal()
		self[start]?.distFromStart=0
		CostCalc(start)
		exploreSurrounding(from: start)
		if explorable.count == 0 {
			return
		}
		var times = 0
		while true {
			if self[goal]!.Explored {
				break
			}
			let results = explore(Goal: goal, Start: start)
			if results {
				break
			}
			times += 1
			if times > Int(width*height*10) {
				break
			}
		}
		var exploredCount = 0
		for (i, val) in nodes.enumerated() {
			for exp in explorable {
				let x = floor(CGFloat(i)/CGFloat(width))
				let y = CGFloat(i)-(x*CGFloat(width))
				if exp == CGPoint(x, y) {
					exploredCount += 1
				}
			}
		}
		let train = trace()
//		print(train)
	}
}
struct Node: Equatable {
	var Property: NodeProperty
	var Explored = false
	var distToGoal: CGFloat?
	var distFromStart: CGFloat?
	var cost: CGFloat?
	var color: (NSColor, NSColor)?
	var parent: CGPoint?
	init(_ Property: NodeProperty) {
		self.Property = Property
	}
	static func == (lhs: Node, rhs: Node) -> Bool {
		return lhs.Property == rhs.Property
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
			.Default: .systemGray,
			.Water: .systemBlue,
			.Wall: .systemRed,
			.Start: .systemPurple,
			.End: .systemYellow,
		]
		for (Property, Color) in ColorTable {
			if self == Property {
				return Color
			}
		}
		return .orange
	}
}
