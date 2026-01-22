extends Control

#----------------------SIGNALS----------------------
signal changeToArenaSelectionScreen
signal changeToWinScreen
signal changeToLoseScreen


#----------------------VARIABLES----------------------
var UI
var player
var game

@export var healthIcon: Array[Texture2D]
@export var projectileDamageIcon: Array[Texture2D]
@export var movementSpeedIcon: Array[Texture2D]
@export var firerateIcon: Array[Texture2D]
@export var maxDashIcon: Array[Texture2D]
@export var dashCooldownIcon: Array[Texture2D]
@export var dashDamageIcon: Array[Texture2D]
@export var shockwaveCostIcon: Array[Texture2D]
@export var shockwaveDamageIcon: Array[Texture2D]
@export var shockwaveRangeIcon: Array[Texture2D]

@onready var backSignals : Array[Signal] = [changeToArenaSelectionScreen, changeToWinScreen, changeToLoseScreen]
var backSignalIndex
@onready var bonusPositiv : Array[String] = [" ","+30%","+60%","+100%" ]
@onready var bonusStacks : Array[String] = [" ","+1","+2","+3" ]
@onready var bonusNegativ : Array[String] = [" ","-30%","-60%","-100%" ]
@onready var bonusTime : Array[String] = [" ", "+10%", "+20%", "+30%"]
@onready var bonusMovement : Array[String] = [" ", "+15%", "+30", "+50%"]


#----------------------INITIALIZATION----------------------

# [ ? ] Initialize UI and set basic icons and skill points
func initializeUI():
	setShockwaveRangeIcon()
	setSkillpoints()


#----------------------UI HANDLER----------------------

# [ ? ] Set skill points label
func setSkillpoints():
	$UpgradesystemBackround/Skillpointtexture/Skillpointslabel.text = str(game.currentSkillPoints)

# [ ? ] Go back to previous screen depending on index
func onBackButtonPressed() -> void:
	backSignals[backSignalIndex].emit()
	UI.buttonClick.play()

# [ ? ] Connect UI scene
func setUIObject(UIObject):
	self.UI = UIObject

# [ ? ] Connect game object
func setGameObject(gameObject):
	self.game = gameObject
	initializeUI()

# [ ? ] Setup player and all icons
func setupPlayer(playerInstance):
	self.player = playerInstance
	setIcons()


#----------------------SKILL POINT MANAGEMENT----------------------

# [ ? ] Update skill points display
func updateSkillPoints(points):
	$UpgradesystemBackround/Skillpointtexture/Skillpointslabel.text = str(points)

# [ ? ] Remove one skill point
func removeSkillPoint():
	game.currentSkillPoints -= 1

# [ ? ] Add one skill point
func addSkillPoint():
	game.currentSkillPoints += 1


#----------------------ICON SETTING----------------------

# [ ? ] Set individual icons based on level
func setHealthIcon(): $"Health/HealthIcon".texture = healthIcon[player.healthLevel]
func setProjectileIcon(): $"Projectile/ProjectileDamage".texture = projectileDamageIcon[player.projectileDamageLevel]
func setMovementIcon(): $"Movement/MovementIcon".texture = movementSpeedIcon[player.movementLevel]
func setFirerateIcon(): $"Firerate/FirerateIcon".texture = firerateIcon[player.fireRateLevel]
func setMaxDashIcon(): $"MaxDash/MaxDashIcon".texture = maxDashIcon[player.dashChargeLevel]
func setDashCooldownIcon(): $DashCooldown/DashCooldownIcon.texture = dashCooldownIcon[player.dashCooldownLevel]
func setDashDamageIcon(): $DashDamage/DashDamageIcon.texture = dashDamageIcon[player.dashDamageLevel]
func setShockwaveCostIcon(): $ShockwaveCost/ShockwaveCostIcon.texture = shockwaveCostIcon[player.shockwaveChargeLevel]
func setShockwaveRangeIcon(): $ShockwaveRange/ShockwaveRangeIcon.texture = shockwaveRangeIcon[player.shockwaveRangeLevel]

# [ ? ] Set all icons at once
func setIcons():
	setHealthIcon()
	setProjectileIcon()
	setMovementIcon()
	setFirerateIcon()
	setMaxDashIcon()
	setDashCooldownIcon()
	setDashDamageIcon()
	setShockwaveCostIcon()
	setShockwaveRangeIcon()


#----------------------LEVEL LABEL SETTING----------------------

# [ ? ] Set label and progress bar for each upgrade
func setHealthLevelLabel(Level, Bonus): $"Health/HealthProgressBar".value = player.healthLevel; $"Label/Bonus/VBoxContainer/HealthLabel".text = Bonus[player.healthLevel]
func setProjectileLevelLabel(Level, Bonus): $"Projectile/ProjectilDamageProgressBar".value = player.projectileDamageLevel; $"Label/Bonus/VBoxContainer/ProjectileLabel".text = Bonus[player.projectileDamageLevel]
func setFireRateLevelLabel(Level, Bonus): $"Firerate/FirerateProgressBar".value = player.fireRateLevel; $"Label/Bonus/VBoxContainer/FirerateLabel".text = Bonus[player.fireRateLevel]
func setMovementLevelLabel(Level, Bonus): $"Movement/MovementProgressBar".value = player.movementLevel; $"Label/Bonus/VBoxContainer/MovementLabel".text = Bonus[player.movementLevel]
func setMaxDashLevelLabel(Level, Bonus): $"MaxDash/MaxDashProgressBar".value = player.dashChargeLevel; $"Label/Bonus/VBoxContainer/MaxDashLabel".text = Bonus[player.dashChargeLevel]
func setDashCooldownLevelLabel(Level, Bonus): $"DashCooldown/DashCooldownProgressBar".value = player.dashCooldownLevel; $"Label/Bonus/VBoxContainer/DashCooldownLabel".text = Bonus[player.dashCooldownLevel]
func setShockwaveChargeLevelLabel(Level, Bonus): $"ShockwaveCost/ShockwaveProgressBar".value = player.shockwaveChargeLevel; $"Label/Bonus/VBoxContainer/ShockwaveCostLabel".text = Bonus[player.shockwaveChargeLevel]
func setShockwaveRangeLevelLabel(Level, Bonus): $"ShockwaveRange/ShockwaveRangeProgressBar".value = player.shockwaveRangeLevel; $"Label/Bonus/VBoxContainer/ShockwaveRangeLabel".text = Bonus[player.shockwaveRangeLevel]


#----------------------BUTTON HANDLERS----------------------
# [ ? ] When the button is pressed, change the values, icons and levels
func onHealthMinusButtonPressed() -> void:
	if (player.healthLevel >= 1):
		addSkillPoint()
		player.healthLevel -= 1
		setHealthIcon()
		setSkillpoints()
		setHealthLevelLabel(player.healthLevel, bonusPositiv)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onHealthPlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.healthLevel < 3):
		removeSkillPoint()
		player.healthLevel += 1
		setHealthIcon()
		setSkillpoints()
		setHealthLevelLabel(player.healthLevel,bonusPositiv)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onProjectileMinusButtonPressed() -> void:
	if (player.projectileDamageLevel >= 1):
		addSkillPoint()
		player.projectileDamageLevel -= 1
		setProjectileIcon()
		setSkillpoints()
		setProjectileLevelLabel(player.projectileDamageLevel, bonusPositiv)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onProjectilePlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.projectileDamageLevel < 3):
		removeSkillPoint()
		player.projectileDamageLevel += 1
		setProjectileIcon()
		setSkillpoints()
		setProjectileLevelLabel(player.projectileDamageLevel, bonusPositiv)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onMovementMinusButtonPressed() -> void:
	if (player.movementLevel >= 1):
		addSkillPoint()
		player.movementLevel -= 1
		setMovementIcon()
		setSkillpoints()
		setMovementLevelLabel(player.movementLevel, bonusMovement)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onMovementPlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.movementLevel < 3):
		removeSkillPoint()
		player.movementLevel += 1
		setMovementIcon()
		setSkillpoints()
		setMovementLevelLabel(player.movementLevel, bonusMovement)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onFirerateMinusButtonPressed() -> void:
	if (player.fireRateLevel >= 1):
		addSkillPoint()
		player.fireRateLevel -= 1
		setFirerateIcon()
		setSkillpoints()
		setFireRateLevelLabel(player.fireRateLevel, bonusTime)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onFireratePlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.fireRateLevel < 3):
		removeSkillPoint()
		player.fireRateLevel += 1
		setFirerateIcon()
		setSkillpoints()
		setFireRateLevelLabel(player.fireRateLevel, bonusTime)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onMaxDashMinusButtonPressed() -> void:
	if (player.dashChargeLevel >= 1):
		addSkillPoint()
		player.dashChargeLevel -= 1
		setMaxDashIcon()
		setSkillpoints()
		setMaxDashLevelLabel(player.dashChargeLevel, bonusStacks)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onMaxDashPlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.dashChargeLevel < 3):
		removeSkillPoint()
		player.dashChargeLevel += 1
		setMaxDashIcon()
		setSkillpoints()
		setMaxDashLevelLabel(player.dashChargeLevel, bonusStacks)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onDashCooldownMinusButtonPressed() -> void:
	if (player.dashCooldownLevel >= 1):
		addSkillPoint()
		player.dashCooldownLevel -= 1
		setDashCooldownIcon()
		setSkillpoints()
		setDashCooldownLevelLabel(player.dashCooldownLevel, bonusTime)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onDashCooldownPlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.dashCooldownLevel < 3):
		removeSkillPoint()
		player.dashCooldownLevel += 1
		setDashCooldownIcon()
		setSkillpoints()
		setDashCooldownLevelLabel(player.dashCooldownLevel, bonusTime)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onDashDamageMinusButtonPressed() -> void:
	if (player.dashDamageLevel >= 1):
		addSkillPoint()
		player.dashDamageLevel -= 1
		setDashDamageIcon()
		setSkillpoints()
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onDashDamagePlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.dashDamageLevel < 3):
		removeSkillPoint()
		player.dashDamageLevel += 1
		setDashDamageIcon()
		setSkillpoints()
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onShockwaveCostMinusButtonPressed() -> void:
	if (player.shockwaveChargeLevel >= 1):
		addSkillPoint()
		player.shockwaveChargeLevel -= 1
		setShockwaveCostIcon()
		setSkillpoints()
		setShockwaveChargeLevelLabel(player.shockwaveChargeLevel, bonusTime)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onShockwaveCostPlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.shockwaveChargeLevel < 3):
		removeSkillPoint()
		player.shockwaveChargeLevel += 1
		setShockwaveCostIcon()
		setSkillpoints()
		setShockwaveChargeLevelLabel(player.shockwaveChargeLevel, bonusTime)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onShockwaveRangeMinusButtonPressed() -> void:
	if (player.shockwaveRangeLevel >= 1):
		addSkillPoint()
		player.shockwaveRangeLevel -= 1
		setShockwaveRangeIcon()
		setSkillpoints()
		setShockwaveRangeLevelLabel(player.shockwaveRangeLevel, bonusPositiv)
	UI.buttonClick.play()

# [ ? ] When the button is pressed, change the values, icons and levels
func onShockwaveRangePlusButtonPressed() -> void:
	if (game.currentSkillPoints >= 1 && player.shockwaveRangeLevel < 3):
		removeSkillPoint()
		player.shockwaveRangeLevel += 1
		setShockwaveRangeIcon()
		setSkillpoints()
		setShockwaveRangeLevelLabel(player.shockwaveRangeLevel, bonusPositiv)
	UI.buttonClick.play()
