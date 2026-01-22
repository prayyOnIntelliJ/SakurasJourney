extends Control


#----------------------SIGNALS----------------------
signal changeToTitleScreen
signal changeToUpgradeScreen
signal tryAgainEmitted


#----------------------VARIABLES----------------------
var UI
@export var frameArray : Array[Texture2D]
@export var buttonNormalArray : Array[Texture2D]
@export var buttonPressedArray : Array[Texture2D]
@export var buttonHoverArray : Array[Texture2D]


#----------------------BUTTON PRESSES----------------------
# [ ? ] Emits signal to change to the title screen when the back button is pressed
func onBackButtonPressed() -> void:
	changeToTitleScreen.emit()
	UI.buttonClick.play()


# [ ? ] Emits signal to change to the upgrade screen when the upgrade button is pressed
func onUpgradeButtonPressed() -> void:
	changeToUpgradeScreen.emit()
	UI.upgradeScreen.backSignalIndex = 2
	UI.buttonClick.play()


# [ ? ] Emits signal to retry when the retry button is pressed
func onRetryButtonPressed() -> void:
	tryAgainEmitted.emit()
	UI.buttonClick.play()


#----------------------UI OBJECT SETTER----------------------
# [ ? ] Sets the UI object for this script
func setUIObject(UIObject):
	self.UI = UIObject


#----------------------FRAME AND BUTTON TEXTURE SETTER----------------------
# [ ? ] Sets the textures for the buttons and frame based on the index
func setFrame(Index):
	$WinOverlayPanel2/TextureRect/Decoration.texture = frameArray[Index]
	$RetryBtn.texture_normal = buttonNormalArray[Index]
	$RetryBtn.texture_pressed = buttonPressedArray[Index]
	$RetryBtn.texture_hover = buttonHoverArray[Index]
	$UpgradeBtn.texture_normal = buttonNormalArray[Index]
	$UpgradeBtn.texture_pressed = buttonPressedArray[Index]
	$UpgradeBtn.texture_hover = buttonHoverArray[Index]
	$BackBtn.texture_normal = buttonNormalArray[Index]
	$BackBtn.texture_pressed = buttonPressedArray[Index]
	$BackBtn.texture_hover = buttonHoverArray[Index]
