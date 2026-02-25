extends Node

var _difficultyLevel: int = -1
var _spawnObject : Node

func setDifficultyLevel(level: int):
	_difficultyLevel = level

func getDifficultyLevel():
	assert (_difficultyLevel != -1, "DifficultyLevel hasn't been set yet.")
	
	return _difficultyLevel

func setSpawnObject(spawnObject: Node):
	_spawnObject = spawnObject

func getSpawnObject():
	if (_spawnObject == null):
		_spawnObject = get_tree().root.find_child("ObjectsInGame", true, false)
	
	assert(_spawnObject != null, "Couldn't find ObjectsInGame in the scene tree.")
	return _spawnObject
