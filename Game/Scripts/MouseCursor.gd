extends Node2D

@onready var fire = $Ghost/Fire


#----------------------INITIALIZATION----------------------
# [ ? ] Sets the mouse mode to hidden on game start
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


#----------------------PROCESSING----------------------
# [ ? ] Updates the global position of the mouse to follow the cursor
func _process(delta: float) -> void:
	global_position = get_global_mouse_position()


#----------------------MOUSE COLOR CHANGES----------------------
# [ ? ] Switches the mouse color to red
func switchMouseColorToRed():
	$Ghost.play("Red")


# [ ? ] Switches the mouse color to blue
func switchMouseColorToBlue():
	$Ghost.play("Blue")
