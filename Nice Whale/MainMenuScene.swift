//
//  MainMenuScene.swift
//  Nice Whale
//
//  Created by Joëlle Rennick on 2020-11-02.
//  Copyright © 2020 Joëlle Rennick. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene{
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "Back")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)

//        let gameBy = SKLabelNode (fontNamed: "RockSalt")
//        gameBy.text = "Joëlle's"
//        gameBy.fontSize = 30
//        gameBy.fontColor = SKColor.white
//        gameBy.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.8)
//        gameBy.zPosition = 1
//        self.addChild(gameBy)

        let gameName1 = SKLabelNode (fontNamed: "RockSalt")
        gameName1.text = "Nice"
        gameName1.fontSize = 150
        gameName1.fontColor = SKColor.white
        gameName1.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.75)
        gameName1.zPosition = 1
        self.addChild(gameName1)

        let gameName2 = SKLabelNode (fontNamed: "RockSalt")
        gameName2.text = "Whale"
        gameName2.fontSize = 150
        gameName2.fontColor = SKColor.white
        gameName2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.65)
        gameName2.zPosition = 1
        self.addChild(gameName2)

        let saveFish = SKLabelNode (fontNamed: "RockSalt")
        saveFish.text = "Free the fish from the boats"
        saveFish.fontSize = 40
        saveFish.fontColor = SKColor.white
        saveFish.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        saveFish.zPosition = 1
        self.addChild(saveFish)
        
        let boatHitYou = SKLabelNode (fontNamed: "RockSalt")
        boatHitYou.text = "Don't let the boats hit you"
        boatHitYou.fontSize = 40
        boatHitYou.fontColor = SKColor.white
        boatHitYou.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.45)
        boatHitYou.zPosition = 1
        self.addChild(boatHitYou)
        
        let boatPassYou = SKLabelNode (fontNamed: "RockSalt")
        boatPassYou.text = "Don't let 3 boats pass you"
        boatPassYou.fontSize = 40
        boatPassYou.fontColor = SKColor.white
        boatPassYou.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.4)
        boatPassYou.zPosition = 1
        self.addChild(boatPassYou)
        
        let startGame = SKLabelNode (fontNamed: "RockSalt")
        startGame.text = "Start Game"
        startGame.fontSize = 100
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.25)
        startGame.zPosition = 1
        startGame.name = "startButton"
        self.addChild(startGame)
        
        let decorBoat = SKSpriteNode(imageNamed: "Boat")
        decorBoat.setScale(0.18)
        decorBoat.position = CGPoint(x: self.size.width/2, y: self.size.height*0.13)
        decorBoat.zPosition  = 1
        decorBoat.zRotation = 67.5
        self.addChild(decorBoat)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            
            if nodeITapped.name == "startButton"{
                let sceneToMoveTo = GameScene(size:self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }

}
