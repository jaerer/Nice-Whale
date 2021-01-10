//
//  GameOverScene.swift
//  Nice Whale
//
//  Created by Joëlle Rennick on 2020-10-17.
//  Copyright © 2020 Joëlle Rennick. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    


    
    
    //Declared globally so that touchesBegan can get access to location
    let restartLabel = SKLabelNode(fontNamed: "RockSalt")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "Back")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let decorBubble = SKSpriteNode(imageNamed: "Bubbles")
        decorBubble.setScale(0.25)
        decorBubble.position = CGPoint(x: self.size.width*0.65, y: self.size.height*0.82)
        decorBubble.zPosition  = 1
        decorBubble.zRotation = 135
        self.addChild(decorBubble)
        let decorBubble2 = SKSpriteNode(imageNamed: "Bubbles")
        decorBubble2.setScale(0.25)
        decorBubble2.position = CGPoint(x: self.size.width*0.35, y: self.size.height*0.82)
        decorBubble2.zPosition  = 1
        self.addChild(decorBubble2)
        
        let decorFish = SKSpriteNode(imageNamed: "Fish")
        decorFish.setScale(0.2)
        decorFish.position = CGPoint(x: self.size.width/2, y: self.size.height*0.82)
        decorFish.zPosition  = 1
        self.addChild(decorFish)
        
        let gameOverLabel = SKLabelNode(fontNamed: "RockSalt")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.65)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "RockSalt")
        scoreLabel.text = "Fish Saved: \(gameScore)"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.5)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        // Load current high
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        //Check to see if new high score and if it is, save it
        if gameScore > highScoreNumber{
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey:"highScoreSaved")
        }
        //Display high score
        let highScoreLabel = SKLabelNode(fontNamed: "RockSalt")
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 60
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.4)
        self.addChild(highScoreLabel)
        
        //Restart label (not button)
        //Label declared globally so that touchesBegan can gain access to location
        restartLabel.text = "Restart"
        restartLabel.fontSize = 100
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.25)
        self.addChild(restartLabel)
        
//        func makeBubble(){
//
//            //Random x coordinate at top to random x coordinate at bottom
//            let randomXStart = random(min:gameArea.minX, max:gameArea.maxX)
//            let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
//            //Starts and end at random x and above top of screen and below screen for y
//            let startPoint = CGPoint(x: randomXStart, y: -self.size.height * 0.2)
//            let endPoint = CGPoint(x: randomXEnd, y: self.size.height * 1.2)
//
//            //Produce bubble now
//            let Bubble = SKSpriteNode(imageNamed: "Bubble")
//            Bubble.name = "Bubble"
//            Bubble.setScale(0.13)
//            Bubble.position = startPoint
//            Bubble.zPosition = 1
//            self.addChild(Bubble)
//
//            let moveBubble = SKAction.move(to: endPoint, duration: 2)
//            let deleteBubble = SKAction.removeFromParent()
//            let bubbleSequence = SKAction.sequence([moveBubble, deleteBubble])
//            Bubble.run(bubbleSequence)
//
//            }
        
    }
    
        //Check if screen was touched where button is. If so, restart game
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            //Find out where screen was touched
            //If touched on label, take back to beginning
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch){
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
        }
    }
}
