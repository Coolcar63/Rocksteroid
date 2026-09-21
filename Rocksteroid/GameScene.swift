//
//  GameScene.swift
//  Rocksteroid
//
//  Created by Anri Shkliar on 20/09/2026.
//

import SpriteKit
import AppKit

enum GameMode: String, CaseIterable {
    case classic = "Classic"
    case endless = "Endless"
    case challenge = "Challenge"
}

enum NodeName {
    static let asteroid = "asteroid"
    static let timeBoost = "timeBoost"
    static let doublePoints = "doublePoints"
    static let score = "score"
    static let level = "level"
    static let highScore = "highScore"
    static let time = "time"
    static let rocket = "rocket"
    static let overlay = "overlay"
    static let event = "event"
    static let pauseButton = "pauseButton"
    static let pauseOverlay = "pauseOverlay"
}

final class GameScene: SKScene {
    private var gameMode: GameMode = .classic
    private var targetScore = 0

    private let gameDuration: TimeInterval = 30
    private let highScoreKey = "spaceRocketHighScore"
    private var score = 0
    private var rocksDestroyed = 0
    private var level = 1
    private var timeRemaining: TimeInterval = 30
    private var doublePointsRemaining: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var timeWithoutAsteroid: TimeInterval = 0
    private var isGameOver = false
    private var isGamePaused = false

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        scaleMode = .resizeFill
        gameMode = MainMenuScene.selectedMode
        startGame()
    }

    private func startGame() {
        print("DEBUG: GameScene starting. Mode = \(gameMode.rawValue), SelectedMode = \(MainMenuScene.selectedMode.rawValue)")
        removeAllChildren()

        score = 0
        rocksDestroyed = 0
        level = 1

        switch gameMode {
        case .classic:
            timeRemaining = gameDuration
            targetScore = 0
        case .endless:
            timeRemaining = 999999
            targetScore = 0
        case .challenge:
            timeRemaining = gameDuration * 2
            targetScore = 50
        }

        doublePointsRemaining = 0
        lastUpdateTime = 0
        timeWithoutAsteroid = 0
        isGameOver = false

        createStarfield()
        createRocket()
        addHUD()
        spawnAsteroid()
    }

    private func createStarfield() {
        backgroundColor = SKColor(red: 0.01, green: 0.018, blue: 0.055, alpha: 1)

        let columns = 12
        let rows = 7
        for index in 0..<(columns * rows) {
            let column = index % columns
            let row = index / columns
            let spacingX = size.width / CGFloat(columns)
            let spacingY = size.height / CGFloat(rows)

            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.45...1.35))
            star.fillColor = [.white, .systemBlue].randomElement() ?? .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.2...0.62)
            star.position = CGPoint(
                x: (CGFloat(column) + 0.5) * spacingX + CGFloat.random(in: -spacingX * 0.32...spacingX * 0.32),
                y: (CGFloat(row) + 0.5) * spacingY + CGFloat.random(in: -spacingY * 0.32...spacingY * 0.32)
            )
            star.zPosition = -10
            addChild(star)
        }
    }

    private func createRocket() {
        let rocket = SKNode()
        rocket.name = NodeName.rocket
        rocket.position = rocketPosition

        let shadow = SKShapeNode(ellipseOf: CGSize(width: 54, height: 16))
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.4
        shadow.position = CGPoint(x: 5, y: -26)
        rocket.addChild(shadow)

        let flameOuter = SKShapeNode(path: flamePath(length: 55, width: 22))
        flameOuter.fillColor = .systemOrange
        flameOuter.strokeColor = .clear
        flameOuter.position = CGPoint(x: -33, y: 0)
        rocket.addChild(flameOuter)

        let flameInner = SKShapeNode(path: flamePath(length: 32, width: 10))
        flameInner.fillColor = .systemYellow
        flameInner.strokeColor = .clear
        flameInner.position = CGPoint(x: -33, y: 0)
        rocket.addChild(flameInner)

        let leftFin = SKShapeNode(path: finPath(isTop: true))
        leftFin.fillColor = .systemRed
        leftFin.strokeColor = SKColor(red: 0.35, green: 0.02, blue: 0.08, alpha: 1)
        leftFin.position = CGPoint(x: -5, y: 0)
        rocket.addChild(leftFin)

        let body = SKShapeNode(path: rocketBodyPath())
        body.fillColor = SKColor(red: 0.72, green: 0.79, blue: 0.91, alpha: 1)
        body.strokeColor = .white
        body.lineWidth = 2
        rocket.addChild(body)

        let highlight = makeRoundedRect(size: CGSize(width: 34, height: 4), cornerRadius: 2)
        highlight.fillColor = .white
        highlight.strokeColor = .clear
        highlight.alpha = 0.55
        highlight.position = CGPoint(x: 5, y: 12)
        rocket.addChild(highlight)

        let window = SKShapeNode(circleOfRadius: 10)
        window.fillColor = SKColor(red: 0.05, green: 0.5, blue: 0.85, alpha: 1)
        window.strokeColor = .white
        window.lineWidth = 2
        window.position = CGPoint(x: 13, y: 0)
        rocket.addChild(window)

        let windowGlow = SKShapeNode(circleOfRadius: 4)
        windowGlow.fillColor = .white
        windowGlow.strokeColor = .clear
        windowGlow.alpha = 0.5
        windowGlow.position = CGPoint(x: 10, y: 4)
        rocket.addChild(windowGlow)

        let cruise = SKAction.sequence([
            .moveBy(x: 5, y: 5, duration: 0.45),
            .moveBy(x: -5, y: -5, duration: 0.45)
        ])
        rocket.run(.repeatForever(cruise))

        flameOuter.run(.repeatForever(.sequence([
            .scaleX(to: 1.25, duration: 0.12),
            .scaleX(to: 0.75, duration: 0.12)
        ])))
        flameInner.run(.repeatForever(.sequence([
            .scaleX(to: 0.7, duration: 0.1),
            .scaleX(to: 1.2, duration: 0.1)
        ])))
        addChild(rocket)
    }

    private var rocketPosition: CGPoint {
        CGPoint(x: max(75, size.width * 0.14), y: size.height * 0.5)
    }

    private func rocketBodyPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -28, y: 0))
        path.addCurve(
            to: CGPoint(x: 34, y: 0),
            control1: CGPoint(x: -5, y: 33),
            control2: CGPoint(x: 24, y: 31)
        )
        path.addCurve(
            to: CGPoint(x: -28, y: 0),
            control1: CGPoint(x: 24, y: -31),
            control2: CGPoint(x: -5, y: -33)
        )
        path.closeSubpath()
        return path
    }

    private func finPath(isTop: Bool) -> CGPath {
        let direction: CGFloat = isTop ? 1 : -1
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -12, y: direction * 17))
        path.addLine(to: CGPoint(x: -23, y: direction * 38))
        path.addLine(to: CGPoint(x: 4, y: direction * 20))
        path.closeSubpath()
        return path
    }

    private func makeRoundedRect(size: CGSize, cornerRadius: CGFloat) -> SKShapeNode {
        let rect = NSRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        let bezierPath = NSBezierPath()
        bezierPath.appendRoundedRect(rect, xRadius: cornerRadius, yRadius: cornerRadius)
        let node = SKShapeNode()
        node.path = bezierPath.cgPath
        return node
    }

    private func flamePath(length: CGFloat, width: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: .zero)

        path.addLine(to: CGPoint(x: -length, y: 0))
        path.addLine(to: CGPoint(x: 0, y: width / 2))
        path.addLine(to: CGPoint(x: 0, y: -width / 2))
        path.closeSubpath()
        return path
    }

    private func addHUD() {
        // Toolbar Background
        let toolbar = SKSpriteNode(color: SKColor(white: 0, alpha: 0.4), size: CGSize(width: size.width, height: 60))
        toolbar.name = "toolbar"
        toolbar.position = CGPoint(x: size.width / 2, y: size.height - 30)
        toolbar.zPosition = 10
        addChild(toolbar)

        let scoreLabel = makeLabel(fontSize: 20, alignment: .left)
        scoreLabel.name = NodeName.score
        scoreLabel.position = CGPoint(x: 24, y: size.height - 30)
        scoreLabel.zPosition = 11
        addChild(scoreLabel)

        let levelLabel = makeLabel(fontSize: 16, alignment: .left)
        levelLabel.name = NodeName.level
        levelLabel.position = CGPoint(x: 24, y: size.height - 50)
        levelLabel.fontColor = .white
        levelLabel.zPosition = 11
        addChild(levelLabel)

        let highScoreLabel = makeLabel(fontSize: 18, alignment: .center)
        highScoreLabel.name = NodeName.highScore
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 30)
        highScoreLabel.fontColor = .white
        highScoreLabel.zPosition = 11
        addChild(highScoreLabel)

        let timeLabel = makeLabel(fontSize: 20, alignment: .right)
        timeLabel.name = NodeName.time
        timeLabel.position = CGPoint(x: size.width - 24, y: size.height - 30)
        timeLabel.zPosition = 11
        addChild(timeLabel)

        // Pause Button
        let pauseBtn = makeRoundedRect(size: CGSize(width: 30, height: 30), cornerRadius: 5)
        pauseBtn.fillColor = SKColor(white: 0.2, alpha: 0.8)
        pauseBtn.strokeColor = .white
        pauseBtn.lineWidth = 1
        pauseBtn.position = CGPoint(x: size.width - 150, y: size.height - 30)
        pauseBtn.name = NodeName.pauseButton
        pauseBtn.zPosition = 12
        addChild(pauseBtn)

        let pauseLabel = SKLabelNode(text: "||")
        pauseLabel.fontName = "Avenir Next Bold"
        pauseLabel.fontSize = 16
        pauseLabel.fontColor = .white
        pauseLabel.verticalAlignmentMode = .center
        pauseLabel.position = CGPoint(x: 0, y: 0)
        pauseBtn.addChild(pauseLabel)

        updateHUD()
    }

    private func togglePause() {
        isGamePaused = !isGamePaused
        self.isPaused = isGamePaused

        if isGamePaused {
            showPauseOverlay()
        } else {
            removePauseOverlay()
        }
    }

    private func showPauseOverlay() {
        let overlay = makeRoundedRect(size: CGSize(width: size.width, height: size.height), cornerRadius: 0)
        overlay.name = NodeName.pauseOverlay
        overlay.fillColor = SKColor(white: 0, alpha: 0.5)
        overlay.strokeColor = .clear
        overlay.zPosition = 100
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(overlay)

        let label = makeLabel(fontSize: 48, alignment: .center)
        label.text = "PAUSED"
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 80)
        overlay.addChild(label)

        let resumeBtn = makeRoundedRect(size: CGSize(width: 200, height: 60), cornerRadius: 30)
        resumeBtn.fillColor = .systemBlue
        resumeBtn.strokeColor = .white
        resumeBtn.lineWidth = 2
        resumeBtn.position = CGPoint(x: 0, y: 0)
        resumeBtn.name = "resumeButton"
        overlay.addChild(resumeBtn)

        let resumeLabel = SKLabelNode(fontNamed: "Avenir Next Bold")
        resumeLabel.text = "RESUME"
        resumeLabel.fontSize = 24
        resumeLabel.fontColor = .white
        resumeLabel.verticalAlignmentMode = .center
        resumeLabel.position = CGPoint(x: 0, y: 0)
        resumeBtn.addChild(resumeLabel)

        let homeBtn = makeRoundedRect(size: CGSize(width: 200, height: 60), cornerRadius: 30)
        homeBtn.fillColor = .systemRed
        homeBtn.strokeColor = .white
        homeBtn.lineWidth = 2
        homeBtn.position = CGPoint(x: 0, y: -80)
        homeBtn.name = "homeButton"
        overlay.addChild(homeBtn)

        let homeLabel = SKLabelNode(fontNamed: "Avenir Next Bold")
        homeLabel.text = "HOME"
        homeLabel.fontSize = 24
        homeLabel.fontColor = .white
        homeLabel.verticalAlignmentMode = .center
        homeLabel.position = CGPoint(x: 0, y: 0)
        homeBtn.addChild(homeLabel)
    }

    private func removePauseOverlay() {
        childNode(withName: NodeName.pauseOverlay)?.removeFromParent()
    }

    private func showConfirmationDialog() {
        let dialog = makeRoundedRect(size: CGSize(width: 500, height: 250), cornerRadius: 20)
        dialog.name = "confirmationDialog"
        dialog.fillColor = SKColor(white: 0.1, alpha: 0.9)
        dialog.strokeColor = .white
        dialog.lineWidth = 2
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dialog.zPosition = 200
        addChild(dialog)

        let text = makeLabel(fontSize: 22, alignment: .center)
        text.text = "Are you sure you want to leave this level?\nIf you leave, you'll lose all your\nprogress and achievements."
        text.numberOfLines = 0
        text.position = CGPoint(x: 0, y: 40)
        dialog.addChild(text)

        let yesBtn = makeRoundedRect(size: CGSize(width: 120, height: 50), cornerRadius: 10)
        yesBtn.fillColor = .systemRed
        yesBtn.strokeColor = .white
        yesBtn.lineWidth = 1
        yesBtn.position = CGPoint(x: -70, y: -50)
        yesBtn.name = "confirmLeave"
        dialog.addChild(yesBtn)

        let yesLabel = SKLabelNode(text: "YES")
        yesLabel.fontName = "Avenir Next Bold"
        yesLabel.fontSize = 20
        yesLabel.fontColor = .white
        yesLabel.verticalAlignmentMode = .center
        yesLabel.position = CGPoint(x: 0, y: 0)
        yesBtn.addChild(yesLabel)

        let noBtn = makeRoundedRect(size: CGSize(width: 120, height: 50), cornerRadius: 10)
        noBtn.fillColor = .systemGray
        noBtn.strokeColor = .white
        noBtn.lineWidth = 1
        noBtn.position = CGPoint(x: 70, y: -50)
        noBtn.name = "cancelLeave"
        dialog.addChild(noBtn)

        let noLabel = SKLabelNode(text: "NO")
        noLabel.fontName = "Avenir Next Bold"
        noLabel.fontSize = 20
        noLabel.fontColor = .white
        noLabel.verticalAlignmentMode = .center
        noLabel.position = CGPoint(x: 0, y: 0)
        noBtn.addChild(noLabel)
    }

    private func removeConfirmationDialog() {
        childNode(withName: "confirmationDialog")?.removeFromParent()
    }

    private func transitionToMenu() {
        let menuScene = MainMenuScene(size: self.size)
        menuScene.scaleMode = .resizeFill
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(menuScene, transition: transition)
    }

    private func makeLabel(fontSize: CGFloat, alignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Avenir Next Bold")
        label.fontSize = fontSize
        label.fontColor = .white
        label.horizontalAlignmentMode = alignment
        label.verticalAlignmentMode = .center
        return label
    }

    private func updateHUD() {
        let highScore = UserDefaults.standard.integer(forKey: highScoreKey)
        (childNode(withName: NodeName.score) as? SKLabelNode)?.text = "Score: \(score)"
        (childNode(withName: NodeName.level) as? SKLabelNode)?.text = "Level \(level)  •  \(rocksDestroyed % 8)/8 rocks"
        (childNode(withName: NodeName.highScore) as? SKLabelNode)?.text = "Best: \(highScore)"

        let timeLabel = childNode(withName: NodeName.time) as? SKLabelNode
        let multiplier = doublePointsRemaining > 0 ? "  2× ACTIVE" : ""

        switch gameMode {
        case .classic:
            timeLabel?.text = "Time: \(Int(ceil(timeRemaining)))\(multiplier)"
        case .endless:
            timeLabel?.text = "ENDLESS MODE\(multiplier)"
        case .challenge:
            timeLabel?.text = "Target: \(targetScore) | Score: \(score)\(multiplier)"
        }

        if let timeLabel = timeLabel, let pauseBtn = childNode(withName: NodeName.pauseButton) {
            let textWidth = timeLabel.frame.width
            pauseBtn.position.x = size.width - 24 - textWidth - 40
        }
    }

    private func spawnAsteroid() {
        guard !isGameOver else { return }

        let radius = CGFloat.random(in: 24...42)
        let asteroid = SKShapeNode(circleOfRadius: radius)
        asteroid.name = NodeName.asteroid
        asteroid.fillColor = SKColor(red: 0.29, green: 0.24, blue: 0.38, alpha: 1)
        asteroid.strokeColor = SKColor(red: 0.76, green: 0.69, blue: 0.9, alpha: 1)
        asteroid.lineWidth = 2
        asteroid.glowWidth = 1
        asteroid.position = CGPoint(
            x: size.width + radius,
            y: CGFloat.random(in: radius + 45...max(radius + 45, size.height - radius - 30))
        )
        asteroid.setScale(0.12)
        asteroid.alpha = 0.45
        addChild(asteroid)

        for _ in 0..<3 {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            crater.fillColor = SKColor(red: 0.13, green: 0.1, blue: 0.2, alpha: 0.9)
            crater.strokeColor = .clear
            crater.position = CGPoint(
                x: CGFloat.random(in: -radius * 0.45...radius * 0.45),
                y: CGFloat.random(in: -radius * 0.45...radius * 0.45)
            )
            asteroid.addChild(crater)
        }

        let travelDuration = max(0.8, 2.5 - Double(level) * 0.18)
        let destination = CGPoint(
            x: max(size.width * 0.46, rocketPosition.x + 170),
            y: asteroid.position.y
        )
        let approach = SKAction.group([
            .move(to: destination, duration: travelDuration),
            .scale(to: 1.65, duration: travelDuration),
            .fadeAlpha(to: 1, duration: travelDuration * 0.45),
            .rotate(byAngle: CGFloat.pi * 2, duration: travelDuration)
        ])
        asteroid.run(.sequence([
            approach,
            .group([.fadeOut(withDuration: 0.18), .scale(to: 2.1, duration: 0.18)]),
            .removeFromParent()
        ]))
    }

    private func spawnPowerUp() {
        guard childNode(withName: NodeName.timeBoost) == nil,
              childNode(withName: NodeName.doublePoints) == nil else { return }

        let isTimeBoost = Bool.random()
        let powerUp = SKShapeNode(circleOfRadius: 24)
        powerUp.name = isTimeBoost ? NodeName.timeBoost : NodeName.doublePoints
        powerUp.fillColor = isTimeBoost ? .systemGreen : .systemYellow
        powerUp.strokeColor = .white
        powerUp.lineWidth = 3
        powerUp.glowWidth = 8
        powerUp.position = CGPoint(
            x: CGFloat.random(in: size.width * 0.5...max(size.width * 0.5, size.width - 55)),
            y: CGFloat.random(in: 70...max(70, size.height - 70))
        )

        let symbol = makeLabel(fontSize: 17, alignment: .center)
        symbol.text = isTimeBoost ? "+15" : "2×"
        symbol.fontColor = .black
        symbol.position.y = -6
        powerUp.addChild(symbol)
        addChild(powerUp)

        powerUp.run(.sequence([
            .repeat(.sequence([.scale(to: 1.15, duration: 0.35), .scale(to: 0.9, duration: 0.35)]), count: 4),
            .fadeOut(withDuration: 0.2),
            .removeFromParent()
        ]))
    }

    private func collectTimeBoost(_ powerUp: SKNode, at location: CGPoint) {
        timeRemaining += 15
        collect(powerUp, at: location, message: "+15 SECONDS", color: .systemGreen)
    }

    private func collectDoublePoints(_ powerUp: SKNode, at location: CGPoint) {
        doublePointsRemaining = 7
        collect(powerUp, at: location, message: "DOUBLE POINTS!", color: .systemYellow)
    }

    private func collect(_ powerUp: SKNode, at location: CGPoint, message: String, color: SKColor) {
        fireLaser(to: location)
        showEvent(message, color: color)
        powerUp.removeAllActions()
        powerUp.run(.sequence([
            .group([.scale(to: 1.8, duration: 0.14), .fadeOut(withDuration: 0.14)]),
            .removeFromParent()
        ]))
        updateHUD()
    }

    private func hit(_ asteroid: SKNode, at location: CGPoint) {
        guard !isGameOver else { return }

        let points = doublePointsRemaining > 0 ? 2 : 1
        score += points
        rocksDestroyed += 1

        let newLevel = rocksDestroyed / 8 + 1
        if newLevel > level {
            level = newLevel
            showEvent("LEVEL \(level) — INCOMING ROCKS FASTER!", color: .systemCyan)
        }

        if score > UserDefaults.standard.integer(forKey: highScoreKey) {
            UserDefaults.standard.set(score, forKey: highScoreKey)
        }
        updateHUD()
        fireLaser(to: location)

        if Int.random(in: 0..<100) < 18 {
            spawnPowerUp()
        }

        asteroid.removeAllActions()
        asteroid.run(.sequence([
            .group([.scale(to: 1.7, duration: 0.12), .fadeOut(withDuration: 0.12)]),
            .removeFromParent()
        ]))
    }

    private func showEvent(_ text: String, color: SKColor) {
        let event = makeLabel(fontSize: 26, alignment: .center)
        event.name = NodeName.event
        event.text = text
        event.fontColor = color
        event.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(event)
        event.run(.sequence([
            .group([.moveBy(x: 0, y: 28, duration: 0.5), .fadeOut(withDuration: 0.5)]),
            .removeFromParent()
        ]))
    }

    private func fireLaser(to target: CGPoint) {
        guard let rocket = childNode(withName: NodeName.rocket) else { return }

        let path = CGMutablePath()
        path.move(to: rocket.position)
        path.addLine(to: target)

        let laser = SKShapeNode(path: path)
        laser.strokeColor = .systemCyan
        laser.lineWidth = 3
        laser.glowWidth = 8
        addChild(laser)
        laser.run(.sequence([.wait(forDuration: 0.06), .fadeOut(withDuration: 0.12), .removeFromParent()]))
    }

    private func winGame() {
        isGameOver = true
        enumerateChildNodes(withName: NodeName.asteroid) { node, _ in
            node.removeAllActions()
        }

        let winLabel = makeLabel(fontSize: 40, alignment: .center)
        winLabel.name = NodeName.overlay
        winLabel.text = "MISSION COMPLETE!"
        winLabel.fontColor = .systemYellow
        winLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 45)
        addChild(winLabel)

        let finalScore = makeLabel(fontSize: 26, alignment: .center)
        finalScore.name = NodeName.overlay
        finalScore.text = "Final score: \(score)"
        finalScore.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(finalScore)

        let restart = makeLabel(fontSize: 22, alignment: .center)
        restart.name = NodeName.overlay
        restart.text = "Click anywhere or press the Space bar to play again"
        restart.position = CGPoint(x: size.width / 2, y: size.height / 2 - 48)
        restart.fontColor = .systemCyan
        restart.run(.repeatForever(.sequence([.fadeAlpha(to: 0.45, duration: 0.8), .fadeAlpha(to: 1, duration: 0.8)])))
        addChild(restart)
    }

    private func endGame() {
        isGameOver = true
        enumerateChildNodes(withName: NodeName.asteroid) { node, _ in
            node.removeAllActions()
        }

        let gameOver = makeLabel(fontSize: 40, alignment: .center)
        gameOver.name = NodeName.overlay
        gameOver.text = "MISSION OVER"
        gameOver.position = CGPoint(x: size.width / 2, y: size.height / 2 + 45)
        addChild(gameOver)

        let finalScore = makeLabel(fontSize: 26, alignment: .center)
        finalScore.name = NodeName.overlay
        finalScore.text = "Final score: \(score)"
        finalScore.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(finalScore)

        let restart = makeLabel(fontSize: 22, alignment: .center)
        restart.name = NodeName.overlay
        restart.text = "Click anywhere or press the Space bar to play again"
        restart.position = CGPoint(x: size.width / 2, y: size.height / 2 - 48)
        restart.fontColor = .systemCyan
        restart.run(.repeatForever(.sequence([.fadeAlpha(to: 0.45, duration: 0.8), .fadeAlpha(to: 1, duration: 0.8)])))
        addChild(restart)
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        // Handle Confirmation Dialog first (highest priority)
        if let dialog = childNode(withName: "confirmationDialog") {
            let localLocation = dialog.convert(location, from: self)
            if dialog.nodes(at: localLocation).contains(where: { $0.name == "confirmLeave" }) {
                removeConfirmationDialog()
                transitionToMenu()
                return
            } else if dialog.nodes(at: localLocation).contains(where: { $0.name == "cancelLeave" }) {
                removeConfirmationDialog()
                return
            }
        }

        if isGamePaused {
            if nodes(at: location).contains(where: { $0.name == "resumeButton" }) {
                togglePause()
            } else if nodes(at: location).contains(where: { $0.name == "homeButton" }) {
                showConfirmationDialog()
            }
            return
        }

        if isGameOver {
            startGame()
            return
        }

        if nodes(at: location).contains(where: { $0.name == NodeName.pauseButton }) {
            togglePause()
            return
        }

        if let asteroid = nodes(at: location).first(where: { $0.name == NodeName.asteroid }) {
            hit(asteroid, at: location)
        } else if let timeBoost = nodes(at: location).first(where: { $0.name == NodeName.timeBoost }) {
            collectTimeBoost(timeBoost, at: location)
        } else if let doublePoints = nodes(at: location).first(where: { $0.name == NodeName.doublePoints }) {
            collectDoublePoints(doublePoints, at: location)
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 0x31, isGameOver {
            startGame()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        guard lastUpdateTime != 0 else {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        if gameMode != .endless {
            timeRemaining = max(0, timeRemaining - deltaTime)
        }
        doublePointsRemaining = max(0, doublePointsRemaining - deltaTime)
        updateHUD()

        if gameMode != .endless && timeRemaining == 0 {
            endGame()
            return
        }

        if gameMode == .challenge && score >= targetScore {
            winGame()
            return
        }

        guard childNode(withName: NodeName.asteroid) == nil else {
            timeWithoutAsteroid = 0
            return
        }

        timeWithoutAsteroid += deltaTime
        let spawnDelay = max(0.18, 0.55 - Double(score) * 0.008)
        if timeWithoutAsteroid >= spawnDelay {
            timeWithoutAsteroid = 0
            spawnAsteroid()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        childNode(withName: NodeName.rocket)?.position = rocketPosition

        if childNode(withName: "toolbar") == nil {
            addHUD()
        } else {
            // Update toolbar position and size on resize
            if let toolbar = childNode(withName: "toolbar") as? SKSpriteNode {
                toolbar.size = CGSize(width: size.width, height: 60)
                toolbar.position = CGPoint(x: size.width / 2, y: size.height - 30)
            }

            // Recalculate absolute positions of HUD elements
            if let score = childNode(withName: NodeName.score) {
                score.position = CGPoint(x: 24, y: size.height - 30)
            }
            if let level = childNode(withName: NodeName.level) {
                level.position = CGPoint(x: 24, y: size.height - 50)
            }
            if let highScore = childNode(withName: NodeName.highScore) {
                highScore.position = CGPoint(x: size.width / 2, y: size.height - 30)
            }
            if let time = childNode(withName: NodeName.time) {
                time.position = CGPoint(x: size.width - 24, y: size.height - 30)
            }
            updateHUD()
        }

        enumerateChildNodes(withName: NodeName.overlay) { node, _ in
            node.position.x = self.size.width / 2
        }
    }
}
