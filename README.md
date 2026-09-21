# 🚀 Rocksteroid

**Rocksteroid** is a fast-paced, arcade-style space shooter for macOS. Navigate your rocket, blast through waves of asteroids, and climb the leaderboard in a fight for survival across the cosmos!
!-- Replace with an actual image link later -->

## 🎮 Game Modes

Choose your challenge from the main menu:

- **🕹️ Classic**: The standard experience. Survive as long as possible and rack up points before the timer hits zero.
- **♾️ Endless**: No timers, no limits. How many asteroids can you destroy before you're overwhelmed?
- **🏆 Challenge**: A race against time. Reach the target score to complete the mission and achieve victory!

## ✨ Key Features

- **Dynamic Difficulty**: The more rocks you destroy, the faster they come.
- **Power-Ups**: 
  - 🟢 **Time Boost**: Adds +15 seconds to your clock.
  - 🟡 **Double Points**: Temporarily doubles your scoring potential.
- **Progression**: Track your levels and save your all-time best high score.

## 🕹️ Controls

- **Mouse**: Click to fire lasers at incoming asteroids.
- **Keyboard**: Press `Space` to restart after a Game Over.

## 📦 Installation (macOS)

1. Download the latest `Rocksteroid.dmg` from the [Releases](#) section of this repository.
2. Open the `.dmg` file.
3. Drag and drop **Rocksteroid** into your **Applications** folder.

### ⚠️ Fixing the "Unidentified Developer" Warning
Since this app is not notarized by Apple, macOS may block it on the first launch. To fix this:

- **The Easy Way**: Right-click `Rocksteroid.app` in your Applications folder $\rightarrow$ Select **Open** $\rightarrow$ Settings $\rightarrow$ Privacy & Security $\rightarrow$ Scroll down $\rightarrow$ Click **Open Anyway**.
- **The Terminal Way**: Open the Terminal app and run the following command:
  ```bash
  xattr -cr /Applications/Rocksteroid.app
  ```

## 🛠️ Development

This project is built using **Swift** and **SpriteKit**.

### Running from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Rocksteroid.git
   ```
2. Open `Rocksteroid.xcodeproj` in **Xcode**.
3. Select the `Rocksteroid` scheme and press `Cmd + R` to run.

---
*Created with 🚀 and Swift.*
