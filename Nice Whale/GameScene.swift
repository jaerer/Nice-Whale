//
//  GameScene.swift
//  Nice Whale
//
//  Created by Joëlle Rennick on 2020-09-18.
//  Copyright © 2020 Joëlle Rennick. All rights reserved.
//

import SpriteKit
import GameplayKit

//Publicly declare so that postGame scene can use this in label
var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //globally decalred for keeping track of game score
    //var not let because we want this number to be able to change
    let scoreLabel = SKLabelNode (fontNamed: "RockSalt")
    
    var livesNumber = 0
    let livesLabel = SKLabelNode (fontNamed: "RockSalt")
    
    //global variable of the level that the player is on
    var levelNumber = 0
    
    //Declared outside of function so that bubbles can be produced under whale no matter where whale moves.
    // Selects asset to be used as whale
    let player = SKSpriteNode(imageNamed: "Whale")
    
    //Declairing bubble sound globally to avoid lag
    //Set to false because sound should not finish before bubbleSequence moves on
    let bubbleSound = SKAction.playSoundFileNamed("Bubbles.wav", waitForCompletion: false)
    let releaseSound = SKAction.playSoundFileNamed("ReleaseFish.wav", waitForCompletion: false)
    
    let tapToStartLabel = SKLabelNode (fontNamed: "RockSalt")

    //Setting up data type to allow scene of before, during and after the game
    enum gameState {
        case preGame //Before
        case inGame //During
        case postGame //After
    }
    
    var currentGameState = gameState.preGame
    
    //Setup of contact by bubble to boat and boat to whale
    struct PhysicsCategories {
        //4 categories to make only contact apply (so that things do not bounce off but instead colide)
        //Numbered to make easier to identify who has hit who
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //binary for 1
        static let Bubble : UInt32 = 0b10 //binary for 2
        static let Boat : UInt32 = 0b100 //binary for 4
    }
    
    
    //Random x coordinate to start and end boats at
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    
    //Pass in min and max range and function will pick between
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    
    //globally declair rectangle to make game margins (for iPhone vs iPad)
    let gameArea: CGRect
    
    override init(size: CGSize){
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        //Setting margin on either side
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)

        super.init(size: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //FUCTION ADD WHALE, BACKGROUND
    // didMove will show what happens immediately (ie Background)
    override func didMove(to view: SKView) {
        
        //Because gameScore is Public, not global, it must be put back in here so that it can be 0 again when game resets
        gameScore = 0
        //Uses the PhysicsContactDelegate to allow bubbles to 'hit' boat
        self.physicsWorld.contactDelegate = self
        
        //BACKGROUND apearance
        //Need a second background to make a scrolling effect
        //Run in for loop so that background 1 and 2 can take place (loop will run as many as i (second number))
        for i in 0...1{
             
         // Selects asset to be used as background
         let background = SKSpriteNode(imageNamed: "Back")
         // Sets background size to same size as scene
         background.size = self.size
         //Making anchor point at bottom of screen instead of middle
             background.anchorPoint = CGPoint(x: 0.5, y: 0)
         // background position (For midpoint to ensure that background
         //is positioned in the middle, divide width by 2 for x and
         //height by 2 for y)
         //y: self.size.height*CGFloat(i) because will start at bottom when i = 0 and start at top when i = 1
         background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
             
         //To layer, z position will send to back. The lower the number
         //the further back
         background.zPosition  = 0
         background.name = "Back"
         //Put all information together
         self.addChild(background)
        }
        
        
        //WHALE
        // Sets player size. 1 is original imported size
        player.setScale(0.12)
        // Whale position: (For midpoint x, divide width by 2. For 20%
        //up the screen, divide height by 5.) but for right now, starts below screen
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        //To layer, z position will send to back. The lower the number
        //the further back. Set to 2 so that bullet can start under.
        player.zPosition  = 1
        //Now player is being applied to SKPhysicsBody code
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        //To combat gravity on player
        player.physicsBody!.affectedByGravity = false
        //Assign into category for physicsBody
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        //Do not want the whale to collide with anything (bounce off)
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        //Do want whale to make contaact with boat (produce explosion)
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Boat
        //Put all information together
        self.addChild(player)
        
        scoreLabel.text = "Fish Saved: 0"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.white
        //As large as the score gets, we always want the score number to expand across the screen
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        //Start score label above screen and have it come into view
        scoreLabel.position = CGPoint(x: self.size.width*0.22, y: self.size.height*0.9 + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Ships Escaped: 0/3"
        livesLabel.fontSize = 40
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.78, y: self.size.height*0.9 + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        //Moving score label and lives label onto screen from above
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.4)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        //Tap to start label
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        //alpha refers to opacity. 1 is 100 there, 0 is invisible
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.4)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    //Stores time of frame so that can compare later
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    //Can change the speed background moves by changing in any function
    var amountToMovePerSecond: CGFloat = 600.0
    //This will run once per game frame (60 times per second)
    //Will move background time amounts quickly for seamless movement
       override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond*CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Back"){
            background, stop in
            if self.currentGameState == gameState.inGame{
            background.position.y -= amountToMoveBackground
            }
            //Once at the bottom, send back up to the top
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
        
    }
    
    
    func startGame(){
        currentGameState = gameState.inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    //lose life function
    func loseLife(){
        livesNumber += 1
        livesLabel.text = "Ships Escaped:\(livesNumber)/3"
        //Makes text bigger temprarily each time a life is lost
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        if livesNumber == 3 {
            runGameOver()
        }
    }
    
    //For adding a point to the score function in DidMove
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Fish Saved: \(gameScore)"
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        scoreLabel.run(scaleSequence)
        //if reach a certain score, up the level
        if gameScore == 10 || gameScore == 20 || gameScore == 30 || gameScore == 50 {
            startNewLevel()
        }
    }
    
    func runGameOver(){
        
        currentGameState = gameState.postGame
        
        self.removeAllActions()
        //Cannot get access to 'bubbles' because they are declared in a function
        //Cannot make 'bubble' global because then it will be asking for two at a time or not allow multiple on screen
        //Must make a list of all bubbles on scene and say removeAllAction of each of those bubbles
        self.enumerateChildNodes(withName: "Bubble"){
            //_,_ in
            bubble, stop in
            bubble.removeAllActions()
        }
        //Same as above but removing action of any boat in scene
        self.enumerateChildNodes(withName: "Boat"){
            Boat, stop in
            Boat.removeAllActions()
        }
        
//        let decorBubbles = SKSpriteNode(imageNamed: "ManyBubbles")
//        decorBubbles.setScale(1)
//        decorBubbles.position = CGPoint(x: self.size.width/2, y: -1.5 - self.size.height)
//        decorBubbles.zPosition  = 2
//        self.addChild(decorBubbles)
//        //let bubbleSound = SKAction.playSoundFileNamed("Bubbles.wav", waitForCompletion: false)
//        let moveManyBubbles = SKAction.moveTo(y: 1.5 + self.size.height, duration: 1.7)
//        let deleteManyBubbles = SKAction.removeFromParent()
//        let manyBubbleSequence = SKAction.sequence([bubbleSound, moveManyBubbles,  deleteManyBubbles])
//        decorBubbles.run(manyBubbleSequence)
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    
    //Stores info for changing from one scene to the next
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        //Removes current scene from view, completes sceneToMoveTo with myTransition
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
        
    }
    
    //Function for when two objects make contact
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        //Checking values of binary assigned to 4 physics body categories
        //if and else assign lower chategory number to body1
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            //if above is true, body's are already lined up in the right order
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        //if above is not true, body1 is a lower number than body2
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        //Defining what to do when Whale is hit by Boat
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Boat{
            //Deletes the object associated with the body (both whale and boat will delete)
            //node? protects from idea that if 2 bubbles hit one boat at the same time the game will shut down
            
            
            //Avoiding case where function tries to pass information but no node exists anymore
            if body1.node != nil {
            //Tells releaseFish function to release fish when boat hits whale
            releaseFish(releasePosition: body1.node!.position)
            }
            if body2.node != nil {
            releaseFish(releasePosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            //If whale and boat have hit, run game over
            runGameOver()
        }
        
        
        //Defining what to do when Bubbles hit the Boat only when the boat is one the screen
        if body1.categoryBitMask == PhysicsCategories.Bubble && body2.categoryBitMask == PhysicsCategories.Boat{
            //Tells releaseFish function to release fish from boat where boat is hit as long as it exists and is on screen
            
            addScore()
            
            if body2.node != nil{
                
                if body2.node!.position.y > self.size.height{
                return
                }
               
                else{
                releaseFish(releasePosition: body2.node!.position)
                }
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
    }
    
    //Function shows fish when bubbles hit boat
    func releaseFish(releasePosition: CGPoint){
        let release = SKSpriteNode(imageNamed: "Fish")
        release.position = releasePosition
        release.zPosition = 3
        release.setScale(0)
        self.addChild(release)
        
        //Actions to make fish look like they are moving
        let scaleIn = SKAction.scale(to: 0.11, duration: 0.12)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let delete = SKAction.removeFromParent()
        let releaseSequence = SKAction.sequence([releaseSound, scaleIn, fadeOut, delete])
        release.run(releaseSequence)
        
    }
        
    func startNewLevel(){
        
        //Anytime we call this function, add 1 to level starting at 1
        levelNumber += 1
        
        //If making boats sequence is already running while level ends, make it stop
        if self.action(forKey: "makingBoats") != nil {
            self.removeAction(forKey: "makingBoats")
        }
        
        //setting up different durations between making of boat per level
        var levelDuration = TimeInterval()
       //Cases is saying if level is 1, make at 1.5 seconds, etc per level
        switch levelNumber {
        case 1: levelDuration = 1.5
        case 2: levelDuration = 1.2
        case 3: levelDuration = 0.9
        case 4: levelDuration = 0.6
        case 5: levelDuration = 0.3
        default:
            //Safety in case something goes wrong
            levelDuration = 0.3
            print("Cannot find level info")
        }
        
        //Makes a boat appear in a loop
        let make = SKAction.run(makeBoat)
        //Delay between each new spawn
        let waitToMake = SKAction.wait(forDuration: levelDuration)
        //Delay one second, then make a boat appear
        let makeSequence = SKAction.sequence([waitToMake, make])
        let makeContinuous = SKAction.repeatForever(makeSequence)
        //Run this on background
        self.run(makeContinuous, withKey: "makingBoats")
        
    }
    
    
    //FUNCTION BLOW BUBBLES
    //Produces bubbles under whale location and moves them up
    func blowBubble() {
        
        //Produce bubble
        let bubble = SKSpriteNode(imageNamed: "Bubbles")
        bubble.name = "Bubble"
        // Sets bubble size. 1 is original imported size
        bubble.setScale(0.08)
        // Sets bubble position. Must start under whale no matter
        //where the whale is
        bubble.position = player.position
        bubble.zPosition = 2
        bubble.physicsBody = SKPhysicsBody(rectangleOf: bubble.size)
        bubble.physicsBody!.affectedByGravity = false
        bubble.physicsBody!.categoryBitMask = PhysicsCategories.Bubble
        //Do not want the bubble to collide with anything (bounce off)
        bubble.physicsBody!.collisionBitMask = PhysicsCategories.None
        //Do want bubble to make contaact with boat (produce explosion)
        bubble.physicsBody!.contactTestBitMask = PhysicsCategories.Boat
        self.addChild(bubble)
        
        // Moves bubbles and then deleted once off screen
        //screen size + bubble size so that it is completely gone
        let moveBubble = SKAction.moveTo(y: self.size.height + bubble.size.height, duration: 1.3)
        // Now delete bubbles to reduce lag in game
        let deleteBubble = SKAction.removeFromParent()
        //Use a sequence to ensure that the run order is sound, movement, delete
        let bubbleSequence = SKAction.sequence([bubbleSound, moveBubble, deleteBubble])
        bubble.run(bubbleSequence)
    }
    
    
    //FUNCTION SHOWS BOAT
    func makeBoat(){
        
        //Random x coordinate at top to random x coordinate at bottom
        let randomXStart = random(min:gameArea.minX, max:gameArea.maxX)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        //Starts and end at random x and above top of screen and below screen for y
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        //Produce boat now
        let Boat = SKSpriteNode(imageNamed: "Boat")
        Boat.name = "Boat"
        Boat.setScale(0.13)
        Boat.position = startPoint
        Boat.zPosition = 1
        Boat.physicsBody = SKPhysicsBody(rectangleOf: Boat.size)
        Boat.physicsBody!.affectedByGravity = false
        Boat.physicsBody!.categoryBitMask = PhysicsCategories.Boat
        //Do not want the boat to collide with anything (bounce off)
        Boat.physicsBody!.collisionBitMask = PhysicsCategories.None
        //Do want boat to make contaact with whale and bullet (produce explosion)
        Boat.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bubble
        self.addChild(Boat)
        
        //Move to end point
        let moveBoat = SKAction.move(to: endPoint, duration: 2)
        //Now delete once off screen
        let deleteBoat = SKAction.removeFromParent()
        //Create sequence to ensure right order
        let loseLifeAction = SKAction.run(loseLife)
        let boatSequence = SKAction.sequence([moveBoat, deleteBoat, loseLifeAction])
        
        //Setting up safety incase boat appears at exact same time as game ends to ensure that if freezes off screen
        if currentGameState == gameState.inGame{
            Boat.run(boatSequence)
        }
        
        //Make boat rotate to face direction it is going
        //Difference between x and y
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        Boat.zRotation = amountToRotate
        
    }
    
    
    //TAP TO PRODUCE BUBBLE
    //Tap anywhere on screen to run bubbleSequence
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        //must be else if because if preGame and then go to startGame, it would then be in game and a bubble would blow right away
        else if currentGameState == gameState.inGame{
            blowBubble()
        }
    }

    
    //MOVES WHALE
    //Allows whale to move and bubbles to move with it
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            // Current coordinates
            let pointOfTouch = touch.location(in: self)
            //Where you were touching before
            let previousPointofTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointofTouch.x
            // Makes location the previous + the new amount dragged
            player.position.x += amountDragged
            //Making sure that whale can only move inGame
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
            }
            
            //To keep whale in game area
            // Too far right
            if player.position.x >= gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            // Too far left
            if player.position.x <= gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
    
}

