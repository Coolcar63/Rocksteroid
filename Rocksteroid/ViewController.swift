//
//  ViewController.swift
//  Rocksteroid
//
//  Created by Anri Shkliar on 20/09/2026.
//

import Cocoa
import SpriteKit

final class ViewController: NSViewController {
    @IBOutlet var skView: NSView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.width, .height]
        view.addSubview(skView)

        let menuScene = MainMenuScene(size: skView.bounds.size)
        menuScene.scaleMode = .resizeFill
        skView.presentScene(menuScene)
    }
}
