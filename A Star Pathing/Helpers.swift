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
	init(_ x: Int, _ y: Int)  {
		self = Self(x: x, y: y)
	}
	init(_ x: CGFloat, _ y: CGFloat)  {
		self = Self(x: x, y: y)
	}
	init(_ x: Float, _ y: Float)  {
		self = Self(x, y)
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
