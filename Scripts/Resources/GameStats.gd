extends Resource
class_name GameStats

var _is_game_running: bool = false
var _spawn_object: Node3D

func is_game_running() -> bool:
	return _is_game_running

func set_is_game_running(is_game_running: bool):
	_is_game_running = is_game_running

func get_spawn_object() -> Node3D:
	return _spawn_object

func set_spawn_object(spawn_object: Node3D):
	_spawn_object = spawn_object
