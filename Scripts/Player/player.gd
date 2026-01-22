extends CharacterBody3D

# ---------------------- SIGNALS ----------------------
signal dashAvailability(available: bool)
signal updateDashStacks(dashStacks)
signal updatePlayerHealth(health)
signal updateShockwaveCharge(charge)
signal gameEnd
signal updateCurrentWeapon(weapon)

# ---------------------- CONSTANTS ----------------------
const PROJECTILE_SPEED : float = 25.0

# ---------------------- ENUMS ----------------------
enum weaponTypes { RED_WEAPON, BLUE_WEAPON }

# ---------------------- EXPORTED VARIABLES ----------------------
@export var accelerationBase: float
@export var maxWalkingSpeedBase: float
@export var dashSpeed : int
@export var dashLengthInSeconds : float
@export var dashCooldownBase: float
@export var maxDashStacksBase: int
@export var stackResetInSeconds : float
@export var fireRateBase: float = 0.4
@export var maxPlayerHPBase : int = 100
@export var maxShockwaveChargeBase: int = 10
@export var shockwaveChargePerKill: int = 10
@export var shockwaveDamageBase: float = 100.0
@export var shockwaveRangeBase: Vector3 = Vector3(10.0, 10.0, 10.0)
@export var projectileDamageBase: float = 10.0
@export var dashDamageBase: float = 20.0
@export var cameraShakeAmount: float = 20.0
@export var shockwaveshader: ShaderMaterial
@export var redProjectileColor : Color
@export var blueProjectileColor : Color
@export var sounds: Array[AudioStreamWAV]

# ---------------------- PLAYER STATS & VARIABLES ----------------------
var acceleration: float
var maxWalkingSpeed: float
var currentSpeed: float
var isFacingLeft: bool = true
var input_dir
var isGameRunning: bool = false
var isDashing : bool = false
var currentDashStacks : int
var dashCooldown : float
var maxDashStacks : int
var dashDirection
var fireRate: float
var maxPlayerHP: int
var maxShockwaveCharge: int
var currentPlayerHP: int
var shockwaveDamage: float
var shockwaveRange: Vector3
var dashDamage: float
var projectileDamage: float
var projectile
var weaponType : weaponTypes
var canShoot: bool = true
var shockwaveIsUsable: bool = false
var shockwaveCharge: int = 0
var projectileOneName : String = "Fire"
var projectileTwoName : String = "Ice"
var tween

# ---------------------- LEVEL MODIFIERS ----------------------
@export var movementLevel := 0
@export var healthLevel := 0
@export var projectileDamageLevel := 0
@export var fireRateLevel := 0
@export var dashChargeLevel := 0
@export var dashCooldownLevel := 0
@export var dashDamageLevel := 0
@export var shockwaveDamageLevel := 0
@export var shockwaveRangeLevel := 0
@export var shockwaveChargeLevel := 0

# ---------------------- MODIFIER ARRAYS ----------------------
@onready var standardModifier := [1.0, 1.3, 1.6, 2.0]
@onready var movementModifier := [1.0, 1.15, 1.3, 1.5]
@onready var timeModifier := [1.0, 0.9, 0.8, 0.7]
@onready var dashModifier := [0, 1, 2, 3, 4]

# ---------------------- SCENE REFERENCES ----------------------
var projectileScene_red = preload("res://Scenes/Projectiles/projectile_red.tscn")
var projectileScene_blue = preload("res://Scenes/Projectiles/projectile_blue.tscn")
var shockwaveScene = preload("res://Scenes/Projectiles/shockwave.tscn")
var shockwaveDashScene = preload("res://Scenes/Projectiles/shockwave_dash.tscn")

# ---------------------- NODE REFERENCES ----------------------
@onready var playerAnimation = $AnimationPlayer/playerAnimationPlayer
@onready var hitAnimation = $AnimationPlayer/hitAnimationPlayer
@onready var textAnimation = $AnimationPlayer/textAnimationPlayer
@onready var audio: AudioStreamPlayer2D = $PlayerAudioPlayer2D
@onready var playerSprite = $PlayerSprite3D
@onready var stackTimer = $Timer/stackTimer
@onready var dashTimer = $Timer/dashTimer
@onready var dashArea = $dashArea3D
@onready var shootTimer = $Timer/shootTimer
@onready var hitAnimations = ["Hit_01", "Hit_02"]

# ---------------------- OBJECT REFERENCES ----------------------
var mouseCursor
var HUD
var spawnObject


# ---------------------- PROCESS LOOP ----------------------
func _physics_process(delta: float) -> void:
	handleMovement(delta)
	handleKeyAction()
	handleDashStacks()
	handleSpriteFlipping()
	handleDashCollisions()
	setShockwaveActiveIfReady()
	updateCursorLocation3D()

	move_and_slide()


# ---------------------- MOVEMENT ----------------------
# [ ? ] Handle player input and movement
func handleMovement(delta):
	if(isGameRunning):
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if(direction == Vector3.ZERO && isDashing):
			direction = dashDirection
		if(isDashing):
			velocity = dashDirection * dashSpeed
		else:
			currentSpeed = min(currentSpeed + acceleration, maxWalkingSpeed) if direction else 0
			velocity = direction * currentSpeed * delta if direction else Vector3.ZERO
		handleAnimations(direction)


# [ ? ] Animation handling for movement
func handleAnimations(direction):
	if(!playerAnimation.current_animation in ["Attack", "Special", "Dash"] &&
			!hitAnimation.current_animation in ["Hit_01", "Hit_02"]
			):
			if(direction):
				playerAnimation.play("Walk")
			else:
				playerAnimation.play("Idle")


# [ ? ] Flip sprite based on direction
func handleSpriteFlipping():
	if(isGameRunning):
		if(input_dir.x > 0 && isFacingLeft):
			playerSprite.flip_h = true
			isFacingLeft = false
		elif(input_dir.x < 0 && !isFacingLeft):
			playerSprite.flip_h = false
			isFacingLeft = true


# ---------------------- INPUT ----------------------
# [ ? ] Input handling for actions
func handleKeyAction():
	if(isGameRunning):
		if(Input.is_action_just_pressed("dash")):
			performDash()
		if(Input.is_action_just_pressed("switch_weapon")):
			switchWeapon()
		if(Input.is_action_pressed("shoot")):
			shoot()
		if(Input.is_action_just_pressed("shockwave")):
			performShockwave()


# ---------------------- DASH ----------------------
# [ ? ] Dash mechanic
func performDash():
	if (!isDashing && currentDashStacks > 0):
		dashTimer.start(dashLengthInSeconds)
		
		dashDirection = (getCursorLocation3D() - global_position).normalized()

		isDashing = true
		currentDashStacks -= 1
		audio.stream = sounds[3]
		audio.play()
		playerAnimation.play("Dash")
		updateDashStacks.emit(currentDashStacks)


# [ ? ] Disable collisions while dashing
func handleDashCollisions():
	var state = isDashing
	set_collision_layer_value(1, !state)
	set_collision_mask_value(2, !state)
	dashArea.monitoring = state


# [ ? ] Manage dash stacks and cooldown
func handleDashStacks():
	if (
		currentDashStacks < maxDashStacks && 
		stackTimer.time_left == 0
	):
		stackTimer.start(stackResetInSeconds)

	if(stackTimer.time_left > 0):
		HUD.updateDashAvailability(stackResetInSeconds - stackTimer.time_left)


# [ ? ] Handles the dash stacks when the timer timeouts
func onStackTimerTimeout() -> void:
	currentDashStacks += 1
	updateDashStacks.emit(currentDashStacks)


# [ ? ] Manage dash stacks and cooldown
func onDashArea3DEntered(body: Node3D) -> void:
	if(!body.has_method("deactivateDashCollision")):
		var shockwave = shockwaveDashScene.instantiate()
		if(isDashing && body.has_method("handleHit")):
			body.handleHit(dashDamage)
			spawnMiniShockwaveOnDash(shockwave)
		elif(isDashing && body.has_method("handleTutorialHit")):
			body.handleTutorialHit(projectileDamage)
			spawnMiniShockwaveOnDash(shockwave)
			


# [ ? ] Spawns a mini shockwave on collision when dashing
func spawnMiniShockwaveOnDash(shockwave):
	shockwave.global_position = global_position
	shockwave.shockwaveDamage = shockwaveDamage
	shockwave.shockwaveRange = Vector3(5,5,5)
	shockwave.setSpawnObject(spawnObject)
	spawnObject.add_child(shockwave)



func onDashtimerTimeout() -> void:
	isDashing = false
	velocity = Vector3.ZERO

# ---------------------- SHOOTING & WEAPON ----------------------
# [ ? ] Shooting mechanic
func shoot():
	if (canShoot):
		canShoot = false
		shootTimer.start(fireRate)
		playerAnimation.play("Attack")
		setupProjectile()


# [ ? ] Setup and spawn projectile
func setupProjectile():
	if(weaponType == weaponTypes.BLUE_WEAPON):
		projectile = projectileScene_blue.instantiate()
	elif(weaponType == weaponTypes.RED_WEAPON):
		projectile = projectileScene_red.instantiate()
	projectile.global_position = $Node3D.global_position + Vector3(0.2, 0, 0).rotated(Vector3(0, 1, 0), $Node3D.rotation.y + 1.5708)
	projectile.linear_velocity = Vector3(PROJECTILE_SPEED, 0, 0).rotated(Vector3(0,1,0), $Node3D.rotation.y + 1.5708)
	projectile.rotation = $Node3D.rotation
	projectile.weaponType = weaponType
	projectile.projectileDamage = projectileDamage
	projectile.setPlayer(self)
	projectile.setSpawnObject(spawnObject)
	spawnObject.add_child(projectile)


# [ ? ] Switch between weapon types
func switchWeapon():
	if (weaponType == weaponTypes.BLUE_WEAPON):
		weaponType = weaponTypes.RED_WEAPON
		mouseCursor.switchMouseColorToRed()
		setText(projectileOneName,2, redProjectileColor)
	elif (weaponType == weaponTypes.RED_WEAPON):
		weaponType = weaponTypes.BLUE_WEAPON
		mouseCursor.switchMouseColorToBlue()
		setText(projectileTwoName, 2, blueProjectileColor)
	updateCurrentWeapon.emit(weaponType)


# [ ? ] Handles the fire rate timer timeout
func onFireRateTimerTimeout():
	canShoot = true

# ---------------------- SHOCKWAVE ----------------------
# [ ? ] Perform shockwave ability
func performShockwave():
	if(shockwaveIsUsable):
		var shockwave = shockwaveScene.instantiate()
		shockwave.global_position = global_position
		shockwave.shockwaveDamage = shockwaveDamage
		shockwave.shockwaveRange = shockwaveRange
		shockwave.setSpawnObject(spawnObject)
		spawnObject.add_child(shockwave)

		resetShockwaveUsability()


# [ ? ] Reset shockwave values
func resetShockwaveUsability():
	shockwaveIsUsable = false
	shockwaveCharge = 0
	updateShockwaveCharge.emit(shockwaveCharge)
	$PlayerSprite3D/SubViewport/Sprite2D.material = null
	playerAnimation.play("Special")


# [ ? ] If the current charge is greater than the max charge, the shockwave will be usable
func setShockwaveActiveIfReady():
	if(shockwaveCharge >= maxShockwaveCharge):
		$PlayerSprite3D/SubViewport/Sprite2D.material = shockwaveshader
		shockwaveIsUsable = true


# [ ? ] Adds shockwave charge
func addShockwaveCharge():
	if(shockwaveCharge < maxShockwaveCharge):
		shockwaveCharge += shockwaveChargePerKill
		updateShockwaveCharge.emit(shockwaveCharge)

# ---------------------- HEALTH ----------------------
# [ ? ] Handle damage when colliding with enemy
func collideWithEnemy(damage):
	playerAnimation.stop()
	var randomHitAnimationNumber = randi_range(0, 1)
	var randomHitAnimation = hitAnimations[randomHitAnimationNumber]
	hitAnimation.play(randomHitAnimation)
	currentPlayerHP -= damage
	shakeCamera(cameraShakeAmount)
	audio.stream = sounds[4]
	audio.play(0.2)
	updatePlayerHealth.emit(currentPlayerHP)


# ---------------------- HELPERS ----------------------
# [ ? ] Updates cursor position in world space
func updateCursorLocation3D():
	$Node3D.look_at(getCursorLocation3D(), Vector3.UP, 0)


# [ ? ] Get cursor position in world space
func getCursorLocation3D():
	var targetPlaneMouse = Plane(Vector3(0, 1, 0), position.y)
	var rayLength = 1000
	var mousePosition = get_viewport().get_mouse_position()
	var from = $PlayerCamera3D.project_ray_origin(mousePosition)
	var to = from + $PlayerCamera3D.project_ray_normal(mousePosition) * rayLength
	var cursorPositionOnPlane = targetPlaneMouse.intersects_ray(from, to)
	return cursorPositionOnPlane


# ---------------------- GAME STATE & SETUP ----------------------
# [ ? ] Handles the game start
func onStartGame(difficulty) -> void:
	resetGameStats()
	setStats()
	visible = true


# [ ? ] Calculates the stats based on a modifier
func setStats():
	maxWalkingSpeed = maxWalkingSpeedBase * movementModifier[movementLevel]
	acceleration = accelerationBase * standardModifier[movementLevel]
	projectileDamage = projectileDamageBase * standardModifier[projectileDamageLevel]
	fireRate = fireRateBase * timeModifier[fireRateLevel]
	maxDashStacks = maxDashStacksBase + dashModifier[dashChargeLevel]
	dashCooldown = dashCooldownBase * timeModifier[dashCooldownLevel]
	dashDamage = dashDamageBase * standardModifier[dashDamageLevel]
	maxShockwaveCharge = maxShockwaveChargeBase * timeModifier[shockwaveChargeLevel]
	shockwaveRange =  shockwaveRangeBase * standardModifier[shockwaveRangeLevel]
	maxPlayerHP = maxPlayerHPBase * standardModifier[healthLevel]
	shockwaveDamage = shockwaveDamageBase * standardModifier[shockwaveDamageLevel]
	currentDashStacks = maxDashStacks
	currentPlayerHP = maxPlayerHP
	updateDashStacks.emit(currentDashStacks)


# [ ? ] Updates the game state
func updateGameState(status: bool):
	isGameRunning = status


# [ ? ] Resets the stats of the player
func resetGameStats():
	currentPlayerHP = maxPlayerHP
	weaponType = weaponTypes.BLUE_WEAPON
	mouseCursor.switchMouseColorToBlue()
	shockwaveCharge = 0
	updateShockwaveCharge.emit(shockwaveCharge)
	hitAnimation.play("RESET")
	playerAnimation.stop()
	$Timer/stackTimer.stop()
	HUD.updateDashAvailability(stackResetInSeconds)
	$PlayerSprite3D/SubViewport/Sprite2D.material = null


# [ ? ] Objects are set in game.gd
func passObjects(mouseCursorObject, HUDObject, spawnObject):
	self.mouseCursor = mouseCursorObject
	self.HUD = HUDObject
	self.spawnObject = spawnObject
	setStats()


# [ ? ] Reset the stats when changing to the main menu
func onPauseScreenChangeToMainMenu() -> void:
	resetGameStats()
	gameEnd.emit()


# [ ? ] When the game is over - reset the stats
func onLevelsGameOver() -> void:
	resetGameStats()


# ---------------------- MISC / UI ----------------------
# [ ? ] Shows a text in the air
func setText(_text, _displaytime, _projectileColor):
	if(tween):
		tween.kill()
	$PlayerSprite3D/PlayerMessage/Timer.start(_displaytime)
	$PlayerSprite3D/PlayerMessage.modulate = Color(_projectileColor.r, _projectileColor.g, _projectileColor.b, 1)
	$PlayerSprite3D/PlayerMessage.text = _text
	$PlayerSprite3D/PlayerMessage.visible = true
	await $PlayerSprite3D/PlayerMessage/Timer.timeout
		
	tween = create_tween()
	tween.tween_property($PlayerSprite3D/PlayerMessage, "modulate", Color(_projectileColor.r, _projectileColor.g, _projectileColor.b, 0) , 0.5)
	# animation player


# ---------------------- CAMERA ----------------------
# [ ? ] Adds a camera shake
func shakeCamera(shakeAmount):
	$PlayerCamera3D.addShake(cameraShakeAmount)


# ---------------------- GETTER METHODS ----------------------
# [ ? ] Returns the time that needs to pass to get a dash stack
func getDashStackResetTime():
	return stackResetInSeconds

# [ ? ] Returns the maximum number of dash stacks
func getMaxDashStacks():
	return maxDashStacks
