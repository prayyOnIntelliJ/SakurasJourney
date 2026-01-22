extends Control


#----------------------SIGNALS----------------------
signal changeToUpgradeScreen
signal changeToArenaSelectionScreen


#----------------------VARIABLES----------------------
var UI
var allCleared: bool
@export var frameArray: Array[Texture2D]
@export var buttonNormalArray: Array[Texture2D]
@export var buttonPressedArray: Array[Texture2D]
@export var buttonHoverArray: Array[Texture2D]


#----------------------BUTTON HANDLERS----------------------
# [ ? ] Emits signal to switch to the upgrade screen and plays click sound
func onUpgradeMenuButtonPressed() -> void:
	changeToUpgradeScreen.emit()
	UI.upgradeScreen.backSignalIndex = 0
	UI.buttonClick.play()


# [ ? ] Emits signal to switch to the arena selection screen and plays click sound
func onArenaSelectionButtonPressed() -> void:
	changeToArenaSelectionScreen.emit()
	UI.upgradeScreen.backSignalIndex = 0
	UI.buttonClick.play()


#----------------------UI HANDLING----------------------
# [ ? ] Assigns the UI object reference to this class
func setUIObject(UIObject):
	self.UI = UIObject


#----------------------SKILLPOINT ANIMATION----------------------
# [ ? ] Plays animation and updates text when skillpoint is earned
func playSkillpointEarned():
	$Sprite2D/skillPointEarnedAnimationPlayer.play("SkillpointEarned")
	$Label.text = "You earned a SKILLPOINT!!!"
	$Sprite2D/Label2.text = "+1"


#----------------------RESET TEXT----------------------
# [ ? ] Resets skillpoint text and stops animations
func resetText():
	$Label.text = "You already earned this SKILLPOINT"
	$Sprite2D/skillPointEarnedAnimationPlayer.stop()
	$Sprite2D/Label2.text = ""
	$UpgradeMenuBtn.modulate = Color(1, 1, 1, 1)


#----------------------ANIMATION CALLBACK----------------------
# [ ? ] Called when skillpoint animation is finished, handles "all cleared" case
func onSkillPointEarnedAnimationPlayerFinished(anim_name: StringName) -> void:
	if (allCleared == true):
		$Sprite2D/skillPointEarnedAnimationPlayer.play("Allcleared")
		$Label.text = "You cleared all difficulties and gained another skillpoint"
		$Sprite2D/Label2.text = "+2"
	else:
		$Sprite2D/skillPointEarnedAnimationPlayer.play("Wobbel")


#----------------------FRAME & BUTTON SKINS----------------------
# [ ? ] Sets the decoration frame and button textures based on index
func setFrame(Index):
	$WinOverlayPanel/TextureRect/Decoration.texture = frameArray[Index]
	$UpgradeMenuBtn.texture_normal = buttonNormalArray[Index]
	$UpgradeMenuBtn.texture_pressed = buttonPressedArray[Index]
	$UpgradeMenuBtn.texture_hover = buttonHoverArray[Index]
	$UpgradeMenuBtn.texture_disabled = buttonPressedArray[Index]
	$ArenaSelectionBtn.texture_normal = buttonNormalArray[Index]
	$ArenaSelectionBtn.texture_pressed = buttonPressedArray[Index]
	$ArenaSelectionBtn.texture_hover = buttonHoverArray[Index]
	$ArenaSelectionBtn.texture_disabled = buttonPressedArray[Index]
	$UpgradeMenuBtn.modulate.a = 1
