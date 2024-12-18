import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameDelegate: GameSceneDelegate?
    weak var coordinator: GameCoordinator?
    var shopManager: ShopManager?
    private var scoreLabelNode: SKLabelNode!
    private var damageFrameNode: SKSpriteNode!
    private var swipeTrailNode: SKShapeNode?
    private var previousSwipePoints: [CGPoint] = []
    private var score = 0 {
        didSet {
            gameDelegate?.didUpdateScore(score)
        }
    }
    
    private var spawnInterval: TimeInterval = 1.2
    private var spawnDecreaseRate: TimeInterval = 0.2
    private var minimumSpawnInterval: TimeInterval = 0.3
    private var elapsedTime: TimeInterval = 0
    private var player: Player!
    init(shopManager: ShopManager, coordinator: GameCoordinator) {
        self.coordinator = coordinator
        super.init(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        loadLevel()
    }

    func loadLevel() {
        self.removeAllChildren()

        startSpawnTimer()
        startFrameSpawning()
        physicsWorld.contactDelegate = self
        setupBackground()
        
        player = Player()
        player.position = CGPoint(x: size.width / 2, y: 100)
        addChild(player)
    }

    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "bg_game")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let moveDirection: CGFloat = location.x > player.position.x ? 20 : -20
        player.move(direction: moveDirection)
        
        player.isBonusActive = coordinator?.isBonus1Active ?? false
        player.isDoubleShotActive = coordinator?.isBonus2Active ?? false

        if player.isBonusActive {
            let bonusBullet = player.shoot()
            addChild(bonusBullet)
        } else if player.isDoubleShotActive {
            let bullets = player.shootDouble()
            bullets.forEach { addChild($0) }
        } else {
            let bullet = player.shoot()
            addChild(bullet)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node as? SKSpriteNode
        let secondBody = contact.bodyB.node as? SKSpriteNode

        if let bullet = firstBody, let monster = secondBody as? Monster {
            handleCollision(bullet: bullet, monster: monster)
        } else if let bullet = secondBody, let monster = firstBody as? Monster {
            handleCollision(bullet: bullet, monster: monster)
        }
        
        if let monster = firstBody as? Monster, secondBody == player {
            handlePlayerCollision(with: monster)
        } else if let monster = secondBody as? Monster, firstBody == player {
            handlePlayerCollision(with: monster)
        }
    }
    
    private func startSpawnTimer() {
        let timerAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.elapsedTime += 1.0
            
            if Int(self.elapsedTime) % 10 == 0 && self.spawnInterval > self.minimumSpawnInterval {
                self.spawnInterval -= self.spawnDecreaseRate
                self.restartSpawning()
            }
        }
        let waitAction = SKAction.wait(forDuration: 1.0)
        run(SKAction.repeatForever(SKAction.sequence([timerAction, waitAction])), withKey: "spawnTimer")
    }
    
    private func startFrameSpawning() {
        let spawnAction = SKAction.run { [weak self] in self?.spawnMonster() }
        let delayAction = SKAction.wait(forDuration: spawnInterval)
        let spawnSequence = SKAction.sequence([spawnAction, delayAction])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawningMonsters")
    }
    
    private func restartSpawning() {
        removeAction(forKey: "spawningMonsters")
        startFrameSpawning()
    }

    func spawnMonster() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let types: [Monster.MonsterType] = [.pink, .blue, .red]
            let randomType = types.randomElement()!
            let position = CGPoint(x: CGFloat.random(in: 50...(self.size.width - 50)), y: self.size.height + 50)
            
            let monster = Monster(type: randomType, position: position)
            
            DispatchQueue.main.async {
                self.addChild(monster)
                
                let fallDuration = TimeInterval.random(in: 5...7)
                let fallAction = SKAction.moveTo(y: -monster.size.height, duration: fallDuration)
                monster.run(SKAction.sequence([fallAction, .removeFromParent()]))
            }
        }
    }

    private func handleCollision(bullet: SKSpriteNode, monster: Monster) {
        bullet.removeFromParent()
        
        let damage = player.isBonusActive ? Int.max : player.weaponDamage
        monster.takeDamage(with: damage)
        
        if monster.health <= 0 {
            switch monster.type {
            case .red: score += 1
            case .blue: score += 2
            case .pink: score += 3
            }
        }
    }

    private func handlePlayerCollision(with monster: Monster) {
        endGame()
    }

    func endGame() {
        self.isPaused = true
        gameDelegate?.didEndGame(win: false, totalScore: score)
    }
}

class Player: SKSpriteNode {
    enum GunType: String {
        case gun1
        case gun2
        case gun3
    }
    
    var isFacingRight = true
    var currentGun: GunType
    var isBonusActive: Bool = false
    var isDoubleShotActive: Bool = false
    
    var weaponDamage: Int {
        if isBonusActive { return Int.max }
        switch currentGun {
        case .gun1: return 1
        case .gun2: return 2
        case .gun3: return 3
        }
    }
    
    let gunTextures: [GunType: (left: SKTexture, right: SKTexture, bullet: String)] = [
        .gun1: (SKTexture(imageNamed: "pers_gun1_left"), SKTexture(imageNamed: "pers_gun1_right"), "gun1_fire"),
        .gun2: (SKTexture(imageNamed: "pers_gun2_left"), SKTexture(imageNamed: "pers_gun2_right"), "gun2_fire"),
        .gun3: (SKTexture(imageNamed: "pers_gun3_left"), SKTexture(imageNamed: "pers_gun3_right"), "gun3_fire")
    ]
    
    init() {
        let selectedSkin = UserDefaults.standard.string(forKey: "SelectedSkin") ?? "gun1"
        self.currentGun = GunType(rawValue: selectedSkin) ?? .gun1
        
        let texture = SKTexture(imageNamed: "pers_\(selectedSkin)_right")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: size)
        self.physicsBody?.categoryBitMask = 0x1 << 0
        self.physicsBody?.contactTestBitMask = 0x1 << 2
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.name = "player"
        self.zPosition = 10
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(direction: CGFloat) {
        self.position.x += direction
        self.texture = direction > 0 ? gunTextures[currentGun]?.right : gunTextures[currentGun]?.left
        isFacingRight = direction > 0
    }
    
    func shoot(offset: CGFloat = 0) -> SKSpriteNode {
        var bulletImage: String
        if isBonusActive {
            bulletImage = "gun_bonus_fire"
        } else {
            bulletImage = gunTextures[currentGun]?.bullet ?? "gun1_fire"
        }
        
        let bullet = SKSpriteNode(imageNamed: bulletImage)
        bullet.position = CGPoint(x: self.position.x + offset, y: self.position.y + 50)
        bullet.zPosition = 5
        bullet.name = "bullet"
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = 0x1 << 1
        bullet.physicsBody?.contactTestBitMask = 0x1 << 2
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.affectedByGravity = false
        bullet.run(SKAction.moveBy(x: 0, y: 1000, duration: 2)) {
            bullet.removeFromParent()
        }
        
        return bullet
    }
    
    func shootDouble() -> [SKSpriteNode] {
        let bulletLeft = shoot(offset: -20)
        let bulletRight = shoot(offset: 20)
        return [bulletLeft, bulletRight]
    }
}

class Monster: SKSpriteNode {
    enum MonsterType {
        case pink, blue, red
    }

    var health: Int
    let type: MonsterType
    var direction: String
    var textures: [SKTexture] = []

    init(type: MonsterType, position: CGPoint) {
        self.type = type
        self.direction = Bool.random() ? "right" : "left"

        switch type {
        case .pink:
            self.health = 10
        case .blue:
            self.health = 8
        case .red:
            self.health = 6
        }
        
        switch type {
        case .pink:
            textures = [
                SKTexture(imageNamed: "pink_monster_\(direction)_3"),
                SKTexture(imageNamed: "pink_monster_\(direction)_2"),
                SKTexture(imageNamed: "pink_monster_\(direction)_1")
            ]
        case .blue:
            textures = [
                SKTexture(imageNamed: "blue_monster_\(direction)_3"),
                SKTexture(imageNamed: "blue_monster_\(direction)_2"),
                SKTexture(imageNamed: "blue_monster_\(direction)_1")
            ]
        case .red:
            textures = [
                SKTexture(imageNamed: "red_monster_\(direction)_3"),
                SKTexture(imageNamed: "red_monster_\(direction)_2"),
                SKTexture(imageNamed: "red_monster_\(direction)_1")
            ]
        }

        let initialTexture = textures.first!
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        self.position = position
        self.zPosition = 5
        self.name = "monster"

        self.physicsBody = SKPhysicsBody(texture: initialTexture, size: self.size)
        self.physicsBody?.categoryBitMask = 0x1 << 2
        self.physicsBody?.contactTestBitMask = 0x1 << 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTexture() {
        switch health {
        case 4...5:
            self.texture = textures[0]
            self.size = textures[0].size()
        case 2...3:
            self.texture = textures[1]
            self.size = textures[1].size()
        case 1:
            self.texture = textures[2]
            self.size = textures[2].size()
        case 0:
            self.run(SKAction.fadeOut(withDuration: 0.5)) {
                self.removeFromParent()
            }
        default:
            break
        }
    }

    func takeDamage(with damage: Int) {
        if damage == Int.max {
            health = 0
        } else {
            let damageModifier: Double
            switch type {
            case .pink:
                damageModifier = 1.0
            case .blue:
                damageModifier = 1.25
            case .red:
                damageModifier = 1.5
            }
            let adjustedDamage = Int(Double(damage) * damageModifier)
            health -= adjustedDamage
        }
        
        if health <= 0 {
            health = 0
            self.run(SKAction.fadeOut(withDuration: 0.5)) {
                self.removeFromParent()
            }
        } else {
            updateTexture()
        }
    }
}
