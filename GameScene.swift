//
//  GameScene.swift
//  Project 11
//
//  Created by Daffolapmac-155 on 21/02/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var array = ["ballRed","ballCyan","ballGrey","ballYellow","ballPurple","ballBlue","ballGreen"]
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    var score = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editingMode: Bool = false{
        didSet{
            if editingMode{
                editLabel.text = "Done"
            }
            else{
                editLabel.text = "Edit"
            }
        }
    }
    
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x:512, y:384)
        background.blendMode = .replace
        background.zPosition = -1
        physicsWorld.contactDelegate = self// used for knowing when 2 physics body collide  and responding appropriately
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        makeSlot(at: CGPoint(x: 128, y:0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y:0) , isGood: false)
        makeSlot(at: CGPoint(x: 640, y:0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y:0), isGood: false)
        
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        scoreLabel.position = CGPoint(x: 980, y: 700)
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        
        editLabel = SKLabelNode(fontNamed: "ChalkDuster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        
        addChild(editLabel)
        addChild(scoreLabel)
        addChild(background)
    }
    // func for detecting  touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let location = touch.location(in: self)
            
            let objects =  nodes(at: location)
            if objects.contains(editLabel){
                editingMode.toggle()
            }else{
                if editingMode{
                    //create a box
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box  = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    
                    
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOf: size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                }
                else{
                    // create a ball
                    //let size = CGSize(width: 26, height: 26)
//                    let ball = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    let ball  = SKSpriteNode(imageNamed: array.randomElement()!)
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody?.restitution = 0.4
//                    var ballLocation = location
//                    guard ballLocation.y >= 700 else{
//                        return
//                    }
                    if location.y >= 600{
                        ball.position = location
                        ball.name = "ball"
                        addChild(ball)
                    }
                   
                }

            }
        }
    }
    // for making bouncer
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0 )
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    // func for adding slots
    func makeSlot(at position: CGPoint, isGood: Bool){
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood{
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"// we should know the object by it's name as per apple recommendation
        }else{
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotGlow.position = position
        slotBase.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        addChild(slotGlow)
        addChild(slotBase)
        // used for rotating the slotglow
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    // inbuilt function called when two bodies first contact with each other
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else{return}
        guard let nodeB = contact.bodyB.node else{return}
        // used to decide which object is ball during collision as ball has to be destroyed
        if nodeA.name == "ball"{
            collisionBetween(ball: nodeA, object: nodeB)
        }else if nodeB.name == "ball"{
            collisionBetween(ball: nodeB, object: nodeA)
        }
//        if contact.bodyA.node?.name == "ball"{
//            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
//        }else if contact.bodyB.node?.name == "ball"{
//            collisionBetween(ball: contact.bodyB.node!, object:contact.bodyA.node! )
//        }
    }
    func collisionBetween(ball: SKNode, object: SKNode){
        if object.name == "good" {
            destroy(ball: ball)
            score+=1
        }else if object.name == "bad"{
            destroy(ball: ball)
            score-=1
        }
    }
    //func for destroying ball when they come in contact
    func destroy(ball: SKNode){
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles"){
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
}
