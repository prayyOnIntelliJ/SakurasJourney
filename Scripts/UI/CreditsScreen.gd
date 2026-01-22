extends Control


#----------------------SIGNALS----------------------
signal changeToTitleScreen


#----------------------VARIABLES----------------------
var UI


#----------------------BUTTON PRESSES----------------------
# [ ? ] Emits the signal to change to the title screen and plays a button click sound
func onTextureButtonPressed() -> void:
	changeToTitleScreen.emit()
	UI.buttonClick.play()


#----------------------UI OBJECT SETTER----------------------
# [ ? ] Sets the UI object for the current scene
func setUIObject(UIObject):
	self.UI = UIObject
