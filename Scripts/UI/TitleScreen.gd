extends Control


#----------------------SIGNALS----------------------
# [ ? ] Signals for changing to different screens
signal changeToSettingsScreen
signal changeToCreditsScreen
signal changeToArenaSelectionScreen


#----------------------VARIABLES----------------------
# [ ? ] Holds the reference to the UI object
var UI


#----------------------BUTTON HANDLERS----------------------
# [ ? ] Handles the Settings button press and triggers the signal to change to the settings screen
func onSettingsButtonPressed() -> void:
	changeToSettingsScreen.emit()
	UI.settingsScreen.backSignalIndex = 0
	UI.buttonClick.play()


# [ ? ] Handles the Credits button press and triggers the signal to change to the credits screen
func onCreditsButtonPressed() -> void:
	changeToCreditsScreen.emit()
	UI.buttonClick.play()


# [ ? ] Handles the New Game button press and triggers the signal to change to the arena selection screen
func onNewGameButtonPressed() -> void:
	changeToArenaSelectionScreen.emit()
	UI.buttonClick.play()


# [ ? ] Handles the Quit Game button press, quitting the game
func onQuitGameButtonPressed() -> void:
	get_tree().quit()


#----------------------UI OBJECT SETTER----------------------
# [ ? ] Sets the UI object reference
func setUIObject(UIObject):
	self.UI = UIObject
