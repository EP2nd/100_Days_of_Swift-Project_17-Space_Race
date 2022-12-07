//
//  GameScene.swift
//  Project17
//
//  Created by Edwin Przeźwiecki Jr. on 26/09/2022.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var restartLabel: SKLabelNode!
    
    var gameTimer: Timer?
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var timeInterval = 1.0
    var enemiesCreated = 0
    
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.zPosition = -1
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        start()
    }
    
    func start() {
        
        player = SKSpriteNode(imageNamed: "player")
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        player.position = CGPoint(x: 100, y: 384)
        addChild(player)
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        score = 0
        enemiesCreated = 0
        timeInterval = 1.0
        isGameOver = false
        
        if let gameOverLabel = gameOverLabel {
            gameOverLabel.removeFromParent()
        }
        
        if let restartLabel = restartLabel {
            restartLabel.removeFromParent()
        }
        
        for node in children {
            if node.name == "Debris" {
                node.removeFromParent()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    /// Challenge 1:
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if children.contains(player) {
            gameOver()
        }
        
        if objects.contains(restartLabel) {
            start()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    @objc func createEnemy() {
        /// Challenge 3:
        if isGameOver {
            return
        }
        
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        sprite.name = "Debris"
        addChild(sprite)
        
        enemiesCreated += 1
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        /// Challenge 2:
        if enemiesCreated >= 20 && enemiesCreated % 20 == 0 {
            
            gameTimer?.invalidate()
            
            if timeInterval >= 0.3 {
                timeInterval -= 0.1
            }
            
            gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    /// Challenge 1:
    func didBegin(_ contact: SKPhysicsContact) {
        gameOver()
    }
    /// Challenge 1:
    func gameOver() {
        
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game over!"
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.zPosition = 1
        addChild(gameOverLabel)
        
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.text = "Restart"
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.position = CGPoint(x: 512, y: 304)
        restartLabel.zPosition = 1
        addChild(restartLabel)
    }
}
