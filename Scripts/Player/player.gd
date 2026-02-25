extends CharacterBody3D

# ---------------------- SIGNALS ----------------------
signal dashAvailability(available: bool)
signal current_dash_stacks_changed(dashStacks)
signal updatePlayerHealth(health)
signal updateShockwaveCharge(charge)
signal gameEnd
signal updateCurrentWeapon(weapon)

# ---------------------- EXPORTED VARIABLES ----------------------
@export var accelerationBase: float
@export var maxWalkingSpeedBase: float
@export var dashCooldownBase: float
@export var maxDashStacksBase: int
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
var currentSpeed: float
var input_dir
var isDashing : bool = false
var dashCooldown : float
var fireRate: float
var maxPlayerHP: int
var maxShockwaveCharge: int
var currentPlayerHP: int
var shockwaveDamage: float
var shockwaveRange: Vector3
var projectileDamage: float
var canShoot: bool = true
var shockwaveCharge: int = 0
var projectileOneName : String = "Fire"
var projectileTwoName : String = "Ice"
var tween
var gameStats: GameStats = preload("res://Scripts/Resources/GameStats.tres")

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

# ---------------------- SCENE REFERENCES ----------------------2
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
@onready var movement_comp: MovementComponent = $MovementComponent
@onready var combat_comp: CombatComponent = $CombatComponent

# ---------------------- OBJECT REFERENCES ----------------------
var mouseCursor
var HUD
var spawnObject


# ---------------------- PROCESS LOOP ----------------------
func _ready() -> void:
	movement_comp.set_player_ref(self)

func _physics_process(delta: float) -> void:
	if(gameStats.is_game_running()):
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		var result = movement_comp.calculate_movement(
			currentSpeed,
			input_dir,
			transform.basis,
			delta
		)

		velocity = result.velocity
		currentSpeed = result.speed
		
		movement_comp.handle_dash_collisions()

		updateCursorLocation3D()
		handleAnimations(result.direction)
		move_and_slide()


# [ ? ] Animation handling for movement
func handleAnimations(direction) -> void:
	if(!playerAnimation.current_animation in ["Attack", "Special", "Dash"] &&
			!hitAnimation.current_animation in ["Hit_01", "Hit_02"]
			):
			if(direction):
				playerAnimation.play("Walk")
			else:
				playerAnimation.play("Idle")


# [ ? ] Flip sprite based on direction
func handleSpriteFlipping():
	if(input_dir.x > 0):
		playerSprite.flip_h = true
	else:
		playerSprite.flip_h = false

func _input(event: InputEvent) -> void:
	if (!gameStats.is_game_running()): return
	
	handleSpriteFlipping()

	if (event.is_action_pressed("dash")):
		movement_comp.perform_dash(getCursorLocation3D(), global_position)
	if (event.is_action_pressed("shockwave")):
		performShockwave()
	if (event.is_action_pressed("switch_weapon")):
		combat_comp.switch_weapon()
	if (event.is_action_pressed("shoot")):
		combat_comp.toggle_shoot(true)
	if (event.is_action_released("shoot")):
		combat_comp.toggle_shoot(false)

# ---------------------- SHOCKWAVE ----------------------
# [ ? ] Perform shockwave ability
func performShockwave():
	if(shockwaveCharge >= maxShockwaveCharge):
		var shockwave = shockwaveScene.instantiate()
		shockwave.global_position = global_position
		shockwave.shockwaveDamage = shockwaveDamage
		shockwave.shockwaveRange = shockwaveRange
		shockwave.setSpawnObject(spawnObject)
		spawnObject.add_child(shockwave)

		resetShockwaveUsability()


# [ ? ] Reset shockwave values
func resetShockwaveUsability():
	shockwaveCharge = 0
	updateShockwaveCharge.emit(shockwaveCharge)
	$PlayerSprite3D/SubViewport/Sprite2D.material = null
	playerAnimation.play("Special")


# [ ? ] Adds shockwave charge
func addShockwaveCharge():
	if(shockwaveCharge < maxShockwaveCharge):
		shockwaveCharge += shockwaveChargePerKill
		updateShockwaveCharge.emit(shockwaveCharge)
	else:
		$PlayerSprite3D/SubViewport/Sprite2D.material = shockwaveshader

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
	movement_comp.max_speed = maxWalkingSpeedBase * movementModifier[movementLevel]
	movement_comp.acceleration = accelerationBase * standardModifier[movementLevel]
	projectileDamage = projectileDamageBase * standardModifier[projectileDamageLevel]
	fireRate = fireRateBase * timeModifier[fireRateLevel]
	movement_comp.max_dash_stacks = maxDashStacksBase + dashModifier[dashChargeLevel]
	dashCooldown = dashCooldownBase * timeModifier[dashCooldownLevel]
	movement_comp.dash_damage = dashDamageBase * standardModifier[dashDamageLevel]
	maxShockwaveCharge = maxShockwaveChargeBase * timeModifier[shockwaveChargeLevel]
	shockwaveRange =  shockwaveRangeBase * standardModifier[shockwaveRangeLevel]
	maxPlayerHP = maxPlayerHPBase * standardModifier[healthLevel]
	shockwaveDamage = shockwaveDamageBase * standardModifier[shockwaveDamageLevel]
	movement_comp.current_dash_stacks = movement_comp.max_dash_stacks
	currentPlayerHP = maxPlayerHP

# [ ? ] Resets the stats of the player
func resetGameStats():
	currentPlayerHP = maxPlayerHP
	combat_comp.weapon_type = combat_comp.weapon_types.BLUE_WEAPON
	mouseCursor.switchMouseColorToBlue()
	shockwaveCharge = 0
	updateShockwaveCharge.emit(shockwaveCharge)
	hitAnimation.play("RESET")
	playerAnimation.stop()
	$Timer/stackTimer.stop()
	HUD.updateDashAvailability(movement_comp.stack_reset_in_seconds)
	$PlayerSprite3D/SubViewport/Sprite2D.material = null


# [ ? ] Objects are set in game.gd
func passObjects(mouseCursorObject, HUDObject):
	self.mouseCursor = mouseCursorObject
	self.HUD = HUDObject
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
	return movement_comp.stack_reset_in_seconds

# [ ? ] Returns the maximum number of dash stacks
func getMaxDashStacks():
	return movement_comp.max_dash_stacks


func on_movement_component_current_dash_stacks_changed(new_dash_stacks: int) -> void:
	current_dash_stacks_changed.emit(new_dash_stacks)


func on_combat_component_on_current_weapon_updated(new_type: CombatComponent.weapon_types) -> void:
	match (new_type):
		combat_comp.new_type.RED_WEAPON:
			setText(projectileOneName, 2, redProjectileColor)
			mouseCursor.switchMouseColorToRed()
		combat_comp.new_type.BLUE_WEAPON:
			setText(projectileTwoName, 2, blueProjectileColor)
			mouseCursor.switchMouseColorToBlue()
