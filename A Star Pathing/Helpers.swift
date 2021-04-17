//
//  Helpers.swift
//  A Star Pathing
//
//  Created by Everett Wilber on 4/16/21.
//

import Foundation
import SpriteKit
import GameplayKit

extension CGPoint {
	static func *(lhs: CGPoint, rhs: Int) -> CGPoint {
		let x = lhs.x * CGFloat(rhs)
		let y = lhs.y * CGFloat(rhs)
		return Self(x, y)
	}
	static func +(lhs: CGPoint, rhs: Int) -> CGPoint {
		let x = lhs.x + CGFloat(rhs)
		let y = lhs.y + CGFloat(rhs)
		return Self(x, y)
	}
	static func -(lhs: CGPoint, rhs: Int) -> CGPoint {
		let x = lhs.x - CGFloat(rhs)
		let y = lhs.y - CGFloat(rhs)
		return Self(x, y)
	}
	static func /(lhs: CGPoint, rhs: Int) -> CGPoint {
		let x = lhs.x / CGFloat(rhs)
		let y = lhs.y / CGFloat(rhs)
		return Self(x, y)
	}
	static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		let x = lhs.x * rhs.x
		let y = lhs.y * rhs.y
		return Self(x, y)
	}
	static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		let x = lhs.x + rhs.x
		let y = lhs.y + rhs.y
		return Self(x, y)
	}
	static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		let x = lhs.x - rhs.x
		let y = lhs.y - rhs.y
		return Self(x, y)
	}
	static func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		let x = lhs.x / rhs.x
		let y = lhs.y / rhs.y
		return Self(x, y)
	}
	init<source>(_ x: source, _ y: source) where source: BinaryFloatingPoint  {
		self = Self(x: CGFloat(x), y: CGFloat(y))
	}
	init(_ point: CGSize) {
		self = Self(point.width, point.height)
	}
}
func abs(_ x: CGPoint) -> CGPoint {
	return CGPoint(abs(x.x), abs(x.y))
}
extension NSColor {
	static func ==(lhs: NSColor, rhs: NSColor) -> Bool {
		let lh = lhs.usingColorSpace(.deviceRGB)!
		let rh = rhs.usingColorSpace(.deviceRGB)!
		let red = lh.redComponent == rh.redComponent
		let green = lh.greenComponent == rh.greenComponent
		let blue = lh.blueComponent == rh.blueComponent
		return (red && green && blue)
	}
}
