extends Control


#----------------------SIGNALS----------------------
signal changeToHUD
signal changeToMainMenu
signal changeToSettingsMenu
var UI


#----------------------EXPORT VARIABLES----------------------
@export var frameArray: Array[Texture2D]
@export var buttonNormalArray: Array[Texture2D]
@export var buttonPressedArray: Array[Texture2D]
@export var buttonHoverArray: Array[Texture2D]


#----------------------BUTTON PRESSES----------------------
# [ ? ] Handles the resume button press, switches to HUD and unpauses the game
func onResumeButtonPressed() -> void:
	changeToHUD.emit()
	get_tree().paused = false
	UI.buttonClick.play()


# [ ? ] Pauses the game when the game pause button is pressed
func onGamePauseGame() -> void:
	get_tree().paused = true
	UI.buttonClick.play()


# [ ? ] Handles the back button press, switches to the main menu
func onBackButtonPressed() -> void:
	changeToMainMenu.emit()
	UI.buttonClick.play()


#----------------------UI OBJECT SETTER----------------------
# [ ? ] Sets the UI object for playing button click sounds
func setUIObject(UIObject):
	self.UI = UIObject


# [ ? ] Handles the settings button press, switches to the settings menu
func onSettingsButtonPressed() -> void:
	changeToSettingsMenu.emit()
	UI.buttonClick.play()
	UI.settingsScreen.backSignalIndex = 1


#----------------------UI FRAME SETTER----------------------
# [ ? ] Sets the frame and button textures for the UI
func setFrame(Index):
	$WinOverlayPanel/TextureRect/Decoration.texture = frameArray[Index]
	$ResumeButton.texture_normal = buttonNormalArray[Index]
	$ResumeButton.texture_pressed = buttonPressedArray[Index]
	$ResumeButton.texture_hover = buttonHoverArray[Index]
	$SettingsButton.texture_normal = buttonNormalArray[Index]
	$SettingsButton.texture_pressed = buttonPressedArray[Index]
	$SettingsButton.texture_hover = buttonHoverArray[Index]
	$BackToMenuButton.texture_normal = buttonNormalArray[Index]
	$BackToMenuButton.texture_pressed = buttonPressedArray[Index]
	$BackToMenuButton.texture_hover = buttonHoverArray[Index]
