extends Control


#----------------------UTILITY REFERENCES----------------------
@onready var playerHealthBar = $PlayerUI/PlayerHealthBar
@onready var sakuraHealthBar = $PlayerUI/SakuraHealthBar
@onready var chargeProgressBar = $PlayerUI/WeaponUI/ChargeProgressCircle
@onready var bossHealthBar = $BossUI/BossHealthBar
@onready var bossIconBackground = $BossUI/BossIconBackground
@onready var arenaTimerProgress = $ArenaTimerUI/ArenaTimerProgressCircle
@onready var dashAvailabilityProgress = $PlayerUI/DashUI/DashAvailabiltyProgress
@onready var dashStackCounter = $PlayerUI/DashUI/DashStackCounter
@onready var weaponSwitchAnimationPlayer = $weaponSwitchAnimationPlayer
@onready var bossUI = $BossUI
@onready var flashMessage = $FlashText/FlashMessage
@onready var flashTextTimer = $FlashText/FlashTextTimer


#----------------------GAME STATE----------------------
var player
var dashStackResetTime
var dashStacks
@export var shockwaveshader: ShaderMaterial


#----------------------IMPORTED VARIABLES----------------------
var maxPlayerHP
var maxSakuraHP
var maxBossHealth
var maxShockwaveCharge
var progressTime
var maxGameTime


#----------------------FLASH MESSAGE PROPERTIES----------------------
@export var flashFontDefaultColor: Color


#----------------------INITIALIZING----------------------
# [ ? ] Called when the scene is ready
func _ready() -> void:
	chargeProgressBar.value = 0


# [ ? ] Initializes default UI values
func initializeDefaultValues():
	arenaTimerProgress.value = 0


#----------------------HEALTH BAR FUNCTIONS----------------------
# [ ? ] Sets max values for player health and shockwave charge bar
func setHealthBarMaxValues(maxPlayerHealth, maxShockwaveCharge):
	playerHealthBar.max_value = maxPlayerHealth
	playerHealthBar.value = maxPlayerHealth
	chargeProgressBar.max_value = maxShockwaveCharge


# [ ? ] Updates player health bar
func setPlayerHealthBar(healthValue):
	playerHealthBar.value = clamp(healthValue, 0, playerHealthBar.max_value)


# [ ? ] Updates Sakura tree health bar
func setSakuraHealthBar(healthValue):
	sakuraHealthBar.value = clamp(healthValue, 0, sakuraHealthBar.max_value)


# [ ? ] Updates boss health bar
func setBossHealthBar(healthValue):
	bossHealthBar.value = clamp(healthValue, 0, bossHealthBar.max_value)


#----------------------SHOCKWAVE CHARGE----------------------
# [ ? ] Updates shockwave charge bar and makes it glow when fully charged
func setShockwaveChargeProgress(chargeValue):
	chargeProgressBar.value = clamp(chargeValue, 0, chargeProgressBar.max_value)
	if (chargeValue >= chargeProgressBar.max_value):
		$PlayerUI/WeaponUI/ChargeProgressCircle/Sprite2D.visible = true
	else:
		$PlayerUI/WeaponUI/ChargeProgressCircle/Sprite2D.visible = false


#----------------------UI VISIBILITY----------------------
# [ ? ] Makes boss UI visible
func setBossUIActive():
	bossUI.visible = true


# [ ? ] Hides boss UI
func setBossUIInactive():
	bossUI.visible = false


# [ ? ] Deactivates all HUD elements
func deactivateHUDElements():
	setBossUIInactive()
	sakuraHealthBar.visible = false
	arenaTimerProgress.visible = true


# [ ? ] Hides arena timer when called
func onLevelsHideTimer() -> void:
	arenaTimerProgress.visible = false


#----------------------GAME TIMER----------------------
# [ ? ] Sets the length of the game
func setGameLength(maxTime):
	chargeProgressBar.max_value = maxTime


# [ ? ] Updates the progress of the game timer
func updateGameLength(timeLeft):
	if (timeLeft != null):
		progressTime = maxGameTime - timeLeft
		arenaTimerProgress.value = progressTime
	else:
		arenaTimerProgress.value = 100


#----------------------DASH SYSTEM----------------------
# [ ? ] Updates dash cooldown UI
func updateDashAvailability(timeLeft):
	dashAvailabilityProgress.value = timeLeft


# [ ? ] Updates dash stacks counter
func onPlayerUpdateDashStacks(dashStacks: Variant) -> void:
	dashStackCounter.text = str(dashStacks)


# [ ? ] Sets the max time for dash stack reset
func setDashStackResetTime(time):
	dashAvailabilityProgress.max_value = time


# [ ? ] Sets the dash counter value
func setDashCounter(dashCounterValue):
	dashStackCounter.text = str(dashCounterValue)


#----------------------PLAYER UPDATES----------------------
# [ ? ] Sets the player instance
func setPlayer(playerInstance):
	self.player = playerInstance


# [ ? ] Sets up player reference
func setupPlayer(playerInstance):
	self.player = playerInstance

#----------------------EVENT HANDLER----------------------
# [ ? ] Initializes everything when game starts
func onGameStart(difficulty) -> void:
	initializeDefaultValues()
	setHealthBarMaxValues(player.maxPlayerHP, player.maxShockwaveCharge)


# [ ? ] Prepares the arena tutorial level
func onArenaSelectionScreenStartTutorialLevel() -> void:
	initializeDefaultValues()
	setHealthBarMaxValues(player.maxPlayerHP, player.maxShockwaveCharge)
	setBossUIActive()
	sakuraHealthBar.visible = true


# [ ? ] Sets boss max health
func onLevelsSetMaxBossHealth(health: Variant) -> void:
	setBossUIActive()
	bossHealthBar.max_value = health
	bossHealthBar.value = health


# [ ? ] Sets Sakura tree max health
func onLevelsSetMaxSakuraHealth(health: Variant) -> void:
	sakuraHealthBar.visible = true
	sakuraHealthBar.max_value = health
	sakuraHealthBar.value = health


# [ ? ] Updates boss tree health
func onLevelsUpdateBossTreeHP(health: Variant) -> void:
	setBossHealthBar(health)


# [ ? ] Updates Sakura tree health
func onLevelsUpdateSakuraTreeHP(health: Variant) -> void:
	setSakuraHealthBar(health)


# [ ? ] Handles game over event
func onLevelsGameOver() -> void:
	deactivateHUDElements()


# [ ? ] Handles returning to main menu
func onPauseScreenChangeToMainMenu() -> void:
	deactivateHUDElements()


# [ ? ] Handles game won event
func onLevelsGameWon() -> void:
	deactivateHUDElements()


# [ ? ] Updates player health from game logic
func onPlayerUpdatePlayerHealth(health: Variant) -> void:
	setPlayerHealthBar(health)


# [ ? ] Receives and sets max game time from level logic
func onLevelsPassMaxGameTime(maxTime: Variant) -> void:
	maxGameTime = maxTime
	arenaTimerProgress.max_value = maxTime


# [ ? ] Updates shockwave charge from player
func onPlayerUpdateShockwaveCharge(charge: Variant) -> void:
	setShockwaveChargeProgress(charge)


# [ ? ] Updates weapon switch animation
func onPlayerUpdateCurrentWeapon(weapon: Variant) -> void:
	if (weapon == 0):
		weaponSwitchAnimationPlayer.play("switch_weapontype")
	else:
		weaponSwitchAnimationPlayer.play_backwards("switch_weapontype")


# [ ? ] Displays flash message on screen
func onFlashMessageDisplay(message, displayTime, textColor):
	if (textColor):
		flashMessage.modulate = textColor
	else: 
		flashMessage.modulate = flashFontDefaultColor
	
	flashTextTimer.wait_time = displayTime
	flashMessage.text = message
	flashTextTimer.start()


# [ ? ] Clears flash message when timer ends
func onFlashTextTimerTimeout() -> void:
	flashMessage.text = ""
