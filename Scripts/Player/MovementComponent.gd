extends Node
class_name MovementComponent

var is_dashing: bool = false
var dash_direction: Vector3 = Vector3.ZERO
var current_dash_stacks: int
var player_ref: CharacterBody3D

signal current_dash_stacks_changed(new_dash_stacks: int)
signal dash_availability_changed(new_time: float)

@export_category("Moving")
@export var acceleration: float = 1
@export var max_speed: float = 100
@export_category("Dashing")
@export_group("Dash Stacks")
@export var max_dash_stacks: int = 1
@export var stack_reset_in_seconds: int = 3
@export var dash_speed: float = 2
@export var dash_length_in_seconds: float = 0.6
@export var dash_damage: int = 30
@export_group("References")
@export var shockwave_dash_scene: PackedScene
@export var dash_timer: Timer
@export var dash_stack_timer: Timer
@export var dash_area: Area3D
@export var audio_stream: AudioStreamPlayer2D
@export var animation_player: AnimationPlayer
@export var dash_sound: AudioStreamWAV


func calculate_movement(
	current_speed: float,
	input_dir: Vector2,
	transform_basis: Basis,
	delta: float
) -> Dictionary:
	var direction = (transform_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if (direction == Vector3.ZERO && is_dashing):
		direction = dash_direction

	var velocity: Vector3
	var new_speed: float

	if (is_dashing):
		velocity = dash_direction * dash_speed
		new_speed = current_speed
	else:
		if (direction != Vector3.ZERO):
			new_speed = min(current_speed + acceleration, max_speed)
			velocity = direction * new_speed * delta
		else:
			new_speed = 0
			velocity = Vector3.ZERO

	return {
		"velocity": velocity,
		"speed": new_speed,
		"direction": direction
	}

func perform_dash(cursor_location: Vector3, current_position: Vector3):
	if (!is_dashing && current_dash_stacks > 0):
		dash_direction = (cursor_location - current_position).normalized()
		is_dashing = true
		current_dash_stacks -= 1
		current_dash_stacks_changed.emit(current_dash_stacks)

		dash_timer.start(dash_length_in_seconds)
		audio_stream.stream = dash_sound
		audio_stream.play()
		animation_player.play("Dash")

func start_dash(direction: Vector3):
	is_dashing = true
	dash_direction = direction
	current_dash_stacks -= 1
	current_dash_stacks_changed.emit(current_dash_stacks)

func stop_dash():
	is_dashing = false

func handle_dash_collisions():
	var state = is_dashing
	player_ref.set_collision_layer_value(1, !state)
	player_ref.set_collision_mask_value(2, !state)
	dash_area.monitoring = state

func update_dash_stacks():
	if (
		current_dash_stacks < max_dash_stacks && 
		dash_stack_timer.time_left == 0
	):
		dash_stack_timer.start(stack_reset_in_seconds)

	if(dash_stack_timer.time_left > 0):
		dash_availability_changed.emit(stack_reset_in_seconds - dash_stack_timer.time_left)
		

func on_stack_timer_timeout() -> void:
	current_dash_stacks += 1


func on_dash_area_3d_body_entered(body: Node3D) -> void:
	if(!body.has_method("deactivateDashCollision")):
		var shockwave = shockwave_dash_scene.instantiate()
		if(is_dashing && body.has_method("handleHit")):
			body.handleHit(dash_damage)
			spawn_mini_shockwave_on_dash(shockwave, body.global_position)
		elif(is_dashing && body.has_method("handleTutorialHit")):
			body.handleTutorialHit(dash_damage)
			spawn_mini_shockwave_on_dash(shockwave, body.global_position)

func spawn_mini_shockwave_on_dash(shockwave, spawn_position: Vector3) -> void:
	shockwave.global_position = spawn_position
	shockwave.shockwaveRange = Vector3(5,5,5)
	shockwave.setSpawnObject(player_ref.spawnObject)
	player_ref.spawnObject.add_child(shockwave)


func on_dash_timer_timeout() -> void:
	stop_dash()
	player_ref.velocity = Vector3.ZERO


func set_player_ref(player_ref: CharacterBody3D) -> void:
	self.player_ref = player_ref
