extends Control


#----------------------SIGNALS----------------------
signal changeToUpgradeMenuScreen
signal changeToTitleScreen
signal changeToArenaSettingsScreen
signal setArenaIndex(index)
signal startTutorialLevel


#----------------------VARIABLES----------------------
var currentArenaIndex: int
var UI


#----------------------GET/SET FUNCTIONS----------------------
# [ ? ] Returns the currently selected arena index
func getCurrentArenaIndex():
	return currentArenaIndex


# [ ? ] Sets the current arena index
func setCurrentArenaIndex(index):
	currentArenaIndex = index


#----------------------BUTTON HANDLERS----------------------
# [ ? ] Navigates to the upgrade menu screen and plays button click sound
func onUpgrademenuNavigationButtonPressed() -> void:
	changeToUpgradeMenuScreen.emit()
	UI.upgradeScreen.backSignalIndex = 0
	_playButtonClick()


# [ ? ] Navigates back to the title screen and plays button click sound
func onBackToTitleButtonPressed() -> void:
	changeToTitleScreen.emit()
	_playButtonClick()


# [ ? ] Navigates to arena settings screen, sets arena index, and plays button click sound
func onArenaButtonPressed(arena_index: int) -> void:
	changeToArenaSettingsScreen.emit()
	setCurrentArenaIndex(arena_index)
	setArenaIndex.emit(arena_index)
	_playButtonClick()


# [ ? ] Shortcut for selecting arena frame 4 (index 3)
func on_arena_frame_04_button_pressed() -> void:
	onArenaButtonPressed(3)


# [ ? ] Shortcut for selecting arena frame 1 (index 0)
func onArenaFrame1ButtonPressed() -> void:
	onArenaButtonPressed(0)


# [ ? ] Shortcut for selecting arena frame 2 (index 1)
func onArenaFrame2ButtonPressed() -> void:
	onArenaButtonPressed(1)


# [ ? ] Shortcut for selecting arena frame 3 (index 2)
func onArenaFrame3ButtonPressed() -> void:
	onArenaButtonPressed(2)


# [ ? ] Starts the tutorial level
func onTextureButtonPressed() -> void:
	startTutorialLevel.emit()


#----------------------AUXILIARY FUNCTION----------------------
# [ ? ] Plays button click sound effect
func _playButtonClick() -> void:
	UI.buttonClick.play()


#----------------------UI OBJECT SETTER----------------------
# [ ? ] Sets the UI object reference
func setUIObject(UIObject):
	self.UI = UIObject
