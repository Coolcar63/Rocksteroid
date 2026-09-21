import SpriteKit
import AppKit

final class MainMenuScene: SKScene {
    static var selectedMode: GameMode = .classic

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.01, green: 0.018, blue: 0.055, alpha: 1)

        setupTitle()
        setupStartButton()
        setupModesButton()
    }

    private func setupTitle() {
        let titleLabel = SKLabelNode(fontNamed: "Avenir Next Bold")
        titleLabel.text = "ROCKSTEROID"
        titleLabel.fontSize = 64
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 100)
        titleLabel.zPosition = 1
        addChild(titleLabel)

        // Add a subtle glow to the title
        let glow = makeRoundedRect(size: CGSize(width: 400, height: 80), cornerRadius: 10)
        glow.fillColor = .clear
        glow.strokeColor = .systemBlue
        glow.lineWidth = 2
        glow.position = titleLabel.position
        glow.zPosition = 0
        addChild(glow)
    }

    private func setupStartButton() {
        let button = makeRoundedRect(size: CGSize(width: 200, height: 60), cornerRadius: 30)
        button.fillColor = .systemBlue
        button.strokeColor = .white
        button.lineWidth = 2
        button.position = CGPoint(x: 0, y: 0)
        button.name = "startButton"
        button.zPosition = 1
        addChild(button)

        let label = SKLabelNode(fontNamed: "Avenir Next Bold")
        label.text = "START GAME"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        button.addChild(label)
    }

    private func setupModesButton() {
        let button = makeRoundedRect(size: CGSize(width: 200, height: 60), cornerRadius: 30)
        button.fillColor = .systemGray
        button.strokeColor = .white
        button.lineWidth = 2
        button.position = CGPoint(x: 0, y: -80)
        button.name = "modesButton"
        button.zPosition = 1
        addChild(button)

        let label = SKLabelNode(fontNamed: "Avenir Next Bold")
        label.text = "GAME MODES"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        button.addChild(label)
    }

    private func showModeSelection() {
        if childNode(withName: "modeOverlay") != nil { return }

        childNode(withName: "startButton")?.isHidden = true
        childNode(withName: "modesButton")?.isHidden = true

        let overlay = SKNode()
        overlay.name = "modeOverlay"
        overlay.zPosition = 10
        overlay.position = CGPoint(x: 0, y: 0)
        addChild(overlay)

        let bg = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bg.fillColor = SKColor(white: 0, alpha: 0.8)
        bg.strokeColor = .clear
        bg.zPosition = -1
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "Avenir Next Bold")
        title.text = "SELECT MODE"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 120)
        overlay.addChild(title)

        for (index, mode) in GameMode.allCases.enumerated() {
            let btn = makeRoundedRect(size: CGSize(width: 250, height: 60), cornerRadius: 15)
            btn.fillColor = (mode == MainMenuScene.selectedMode) ? .systemBlue : .systemGray
            btn.strokeColor = .white
            btn.lineWidth = 2
            btn.position = CGPoint(x: 0, y: CGFloat(index * -80))
            btn.name = mode.rawValue

            btn.zPosition = 1
            overlay.addChild(btn)

            let label = SKLabelNode(fontNamed: "Avenir Next Bold")
            label.text = mode.rawValue
            label.fontSize = 24
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: 0)
            btn.addChild(label)
        }
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let clickedNodes = nodes(at: location)

        // 1. Check for specific buttons first
        if clickedNodes.contains(where: { $0.name == "startButton" }) {
            transitionToGame()
            return
        }

        if clickedNodes.contains(where: { $0.name == "modesButton" }) {
            showModeSelection()
            return
        }

        // 2. Check for mode selection buttons
        if let modeNode = clickedNodes.first(where: { $0.name != nil && GameMode(rawValue: $0.name!) != nil }) {
            if let mode = GameMode(rawValue: modeNode.name!) {
                MainMenuScene.selectedMode = mode
                enumerateChildNodes(withName: "modeOverlay") { node, _ in node.removeFromParent() }
                childNode(withName: "startButton")?.isHidden = false
                childNode(withName: "modesButton")?.isHidden = false
                return
            }
        }
    }

    private func makeRoundedRect(size: CGSize, cornerRadius: CGFloat) -> SKShapeNode {
        let rect = NSRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        let bezierPath = NSBezierPath()
        bezierPath.appendRoundedRect(rect, xRadius: cornerRadius, yRadius: cornerRadius)
        let node = SKShapeNode()
        node.path = bezierPath.cgPath
        return node
    }

    private func transitionToGame() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .resizeFill

        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
