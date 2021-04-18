//
//  GameScene.swift
//  A Star Pathing
//
//  Created by Everett Wilber on 4/16/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
	private var xWidth: Int = 10/2
	private var yWidth: Int = 10/2
	private var nodeGrid: NodeGrid = NodeGrid(width: 1, height: 1)
	private var oldNodes: [Node]?
	
	private var mousePos = CGPoint()
	private var clickID = 0
	
	private var NodesChanged: [(Int, Int)] = []
	private var CurrentChangingColor: NodeProperty?
	
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
	private var coordMultiplier: CGPoint = CGPoint()
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
		let nodeShrink: CGFloat = 2
		let node = CGSize.init(width: (self.size.width/CGFloat(xWidth))/nodeShrink, height: (self.size.height/CGFloat(yWidth))/nodeShrink)
		self.spinnyNode = SKShapeNode(rectOf: node)
		spinnyNode?.fillColor = .white
		let xcoords = Array(-xWidth..<xWidth)
		let ycoords = Array(-yWidth..<yWidth)
		coordMultiplier = CGPoint((node.width*nodeShrink), (node.height*nodeShrink))
		for (xnum, xScreen) in xcoords.enumerated() {
			for (ynum, yScreen) in ycoords.enumerated(){
				print(coordMultiplier)
				let pos = CGPoint(x: xScreen, y: yScreen)
				if let node = self.spinnyNode?.copy() as! SKShapeNode? {
					node.position = pos * (coordMultiplier-(coordMultiplier/2)) + (coordMultiplier/4)
					node.strokeColor = .black
					node.fillColor = .gray
					node.lineWidth = 6
					node.name = String(xnum) + ":" + String(ynum)
					self.addChild(node)
				}
			}
		}
		
		//create the node grid
		nodeGrid = NodeGrid(width: xWidth*2, height: yWidth*2)
		
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//			print(pos)
//            n.position = pos
//            self.addChild(n)
//        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
	func findChild(pos: CGPoint) -> SKShapeNode? {
		for aChild in self.children {
			if let child = aChild as? SKShapeNode {
				if aChild.contains(pos) {
					return child
				}
			}
		}
		return nil
	}
	func CoordDecoder(name: String) -> (Int, Int) {
		let parts = name.split(separator: ":")
		var crds:[Int] = []
		for part in parts {
			crds.append(Int(String(part)) ?? 0)
		}
		return (crds[0], crds[1])
	}
	func ClickHandler() {
		for aChild in self.children {
			if let child = aChild as? SKShapeNode {
				if aChild.contains(mousePos) {
					var IsFirst = NodesChanged.count == 0
					var coords: (Int, Int)
					if let parts = child.name?.split(separator: ":") {
						var crds:[Int] = []
						for part in parts {
							crds.append(Int(String(part)) ?? 0)
						}
						coords = (crds[0], crds[1])
					} else {
						break
					}
					if NodesChanged.contains(where: {($0.0 == coords.0)&&($0.1 == coords.1)}) {
						print(coords)
						break
					}
					NodesChanged.append(coords)
					let currentProperty = nodeGrid[coords.0, coords.1].Property
					if currentProperty == .Water {
						nodeGrid[coords.0, coords.1].Property = .Wall
					} else if currentProperty == .Wall {
						nodeGrid[coords.0, coords.1].Property = .Default
					} else if currentProperty == .Default {
						nodeGrid[coords.0, coords.1].Property = .Water
					}
					if IsFirst {
						CurrentChangingColor = nodeGrid[coords.0, coords.1].Property
					} else {
						nodeGrid[coords.0, coords.1].Property = CurrentChangingColor!
					}
					child.fillColor = nodeGrid[coords.0, coords.1].Property.Color
				}
			}
		}
	}
	
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
		mousePos = event.location(in: self)
		clickID += 1
		ClickHandler()
    }
	override func rightMouseDown(with event: NSEvent) {
		var child = findChild(pos: event.location(in: self))
		let Coord = CoordDecoder(name: child!.name!)
		if nodeGrid[Coord.0, Coord.1].Property == .Start {
			nodeGrid[Coord.0, Coord.1].Property = .End
		} else {
			nodeGrid[Coord.0, Coord.1].Property = .Start
		}
		child!.fillColor = nodeGrid[Coord.0, Coord.1].Property.Color
		
	}
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
		mousePos = event.location(in: self)
		ClickHandler()
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
		mousePos = event.location(in: self)
		NodesChanged.removeAll()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
		if (nodeGrid.findGoal() != CGPoint.zero) && (nodeGrid.findStart() != CGPoint.zero) {
			if oldNodes ?? [] != nodeGrid.nodes{
				nodeGrid.solve()
			}
			if nodeGrid.nodes != oldNodes ?? [] {
				for aChild in self.children {
					if let child = aChild as? SKShapeNode {
						let coords: (Int, Int) = CoordDecoder(name: child.name!)
						child.fillColor = nodeGrid[coords.0, coords.1].Property.Color
						if nodeGrid[coords.0, coords.1].Explored {
							child.strokeColor = .white
						} else {
							child.strokeColor = .black
						}
					}
				}
			}
		} else {
			for aChild in self.children {
				if let child = aChild as? SKShapeNode {
					child.strokeColor = .black
				}
			}
		}
        self.lastUpdateTime = currentTime
    }
}
