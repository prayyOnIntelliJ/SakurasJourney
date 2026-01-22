extends Camera3D


#-------------------CAMERA SHAKE SETTINGS-------------------
# [ ? ] Settings for controlling the camera shake behavior
@export var cameraShakeReductionRate: float = 1.0
@export var max_x: float = 1.0
@export var max_y: float = 1.0
@export var max_z: float = 1.0
@export var noise_speed: float = 1000.0
@export var noise: FastNoiseLite


#-------------------CAMERA SHAKE VARIABLES-------------------
# [ ? ] Variables used for controlling the camera shake effect
var shake: float = 0.0
var time: float = 0.0

@onready var initial_rotation: Vector3 = rotation_degrees


#-------------------PROCESS FUNCTION-------------------
# [ ? ] The process function that updates camera shake every frame
func _process(delta: float) -> void:
	time += delta
	shake = max(shake - delta * cameraShakeReductionRate, 0.0)

	var intensity = get_shake_intensity()

	var noise_x = get_noise_from_seed(0)
	var noise_y = get_noise_from_seed(1)
	var noise_z = get_noise_from_seed(2)

	rotation_degrees.x = lerp(rotation_degrees.x, initial_rotation.x + max_x * intensity * noise_z, 0.5)
	rotation_degrees.y = lerp(rotation_degrees.y, initial_rotation.y + max_y * intensity * noise_y, 0.5)


#-------------------SHAKE CONTROL-------------------
# [ ? ] Adds shake to the camera by increasing the shake intensity
func addShake(shake_amount: float):
	shake = clamp(shake + shake_amount, 0.0, 1.0)


#-------------------SHAKE INTENSITY-------------------
# [ ? ] Returns the intensity of the shake, squared for greater effect
func get_shake_intensity() -> float:
	return shake * shake


#-------------------NOISE FUNCTION-------------------
# [ ? ] Returns a noise value based on the seed offset and time
func get_noise_from_seed(seed_offset: int) -> float:
	return noise.get_noise_1d((time + seed_offset) * noise_speed)
