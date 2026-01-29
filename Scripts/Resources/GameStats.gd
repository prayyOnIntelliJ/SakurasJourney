extends Resource
class_name GameStats

var _isGameRunning: bool = false

func isGameRunning():
	return _isGameRunning

func setIsGameRunning(isGameRunning: bool):
	_isGameRunning = isGameRunning
