extends Area3D


#----------------------VARIABLES----------------------
@export_multiline var text : String
@export var text_color : Color
@export var displaytime : float


#----------------------SIGNAL HANDLING----------------------
# [ ? ] Triggered when a body enters the area; checks if the body can set the text and displays it
func on_body_entered(body: Node3D) -> void:
	if (body.has_method("setText")):
		# [ ? ] Sets the text on the body, with the specified duration and color
		body.setText(text, displaytime, text_color)
