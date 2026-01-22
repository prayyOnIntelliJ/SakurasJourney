extends Control


#----------------------SIGNALS----------------------
signal clearLevel


#----------------------VARIABLES----------------------
var player

@onready var buttonClick = $UI_Audio/Buttonclick
@onready var upgradeScreen = $UpgradeScreen
@onready var winScreen = $WinScreen
@onready var failScreen = $FailScreen
@onready var pauseScreen = $PauseScreen
@onready var settingsScreen = $SettingsScreen
@onready var titleScreen = $TitleScreen
@onready var creditsScreen = $CreditsScreen
@onready var arenaSelectionScreen = $ArenaSelectionScreen
@onready var arenaSettingsScreen = $ArenaSettingsScreen
@onready var Hud = $Hud

@onready var UIAudio = $UI_Audio
@onready var musicPlayer = $Musicplayer
@onready var musicPlayerBattleMusic = $Musicplayer/Battlemusic


#----------------------INITIALIZATION----------------------
# [ ? ] Initializes the UI object for all child elements
func _ready() -> void:
	passUIObject()


#----------------------SCREEN MANAGEMENT----------------------
# [ ? ] Sets the active screen by hiding all other screens and showing the provided screen
func setActiveScreen(screen: Control):
	for screens in get_children():
		screens.visible = false
	UIAudio.play()
	screen.visible = true


#----------------------SCREEN TRANSITIONS----------------------
# [ ? ] Changes to the title screen
func onChangeToTitleScreen() -> void:
	setActiveScreen(titleScreen)


# [ ? ] Changes to the arena selection screen
func onChangeToArenaSelectionScreen() -> void:
	setActiveScreen(arenaSelectionScreen)


# [ ? ] Changes to the arena settings screen
func onChangeToArenaSettingsScreen() -> void:
	setActiveScreen(arenaSettingsScreen)


# [ ? ] Changes to the settings screen
func onChangeToSettingsScreen() -> void:
	setActiveScreen(settingsScreen)


# [ ? ] Changes to the credits screen
func onChangeToCreditsScreen() -> void:
	setActiveScreen(creditsScreen)


# [ ? ] Changes to the HUD screen
func onChangeToHUD() -> void:
	setActiveScreen(Hud)


# [ ? ] Changes to the pause screen
func onChangeToPauseScreen() -> void:
	setActiveScreen(pauseScreen)


# [ ? ] Changes to the fail screen
func onChangeToFailScreen() -> void:
	setActiveScreen(failScreen)


# [ ? ] Changes to the upgrade screen
func onChangeToUpgradeScreen() -> void:
	setActiveScreen(upgradeScreen)


# [ ? ] Changes from the upgrade screen to the win screen
func onUpgradeScreenChangeToWinScreen() -> void:
	setActiveScreen(winScreen)


# [ ? ] Changes from the win screen back to the arena selection screen
func onWinScreenChangeToArenaSelectionScreen() -> void:
	setActiveScreen(arenaSelectionScreen)
	musicPlayer.play()
	musicPlayerBattleMusic.stop()


# [ ? ] Changes from the fail screen to the title screen
func onFailScreenChangeToTitleScreen() -> void:
	setActiveScreen(titleScreen)
	musicPlayer.play()
	musicPlayerBattleMusic.stop()


# [ ? ] Changes from the pause screen to the main menu
func onPauseScreenChangeToMainMenu() -> void:
	setActiveScreen(titleScreen)
	clearLevel.emit()
	musicPlayer.play()
	musicPlayerBattleMusic.stop()


#----------------------AUDIO MANAGEMENT----------------------
# [ ? ] Plays the SFX sound when the settings screen is active
func onSettingsScreenPlaySFXSound() -> void:
	UIAudio.play()


#----------------------UTILITY FUNCTIONS----------------------
# [ ? ] Passes the UI object to all child elements that have the "setUIObject" method
func passUIObject():
	for child in get_children():
		if (child.has_method("setUIObject")):
			child.setUIObject(self)


# [ ? ] Sets the player instance and passes it to relevant screens
func setPlayer(playerInstance):
	self.player = playerInstance

	Hud.setupPlayer(player)
	upgradeScreen.setupPlayer(player)
