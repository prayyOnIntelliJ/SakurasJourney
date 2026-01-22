extends Control


#----------------------SIGNALS----------------------
signal changeToArenaSelectionScreen
signal startGame(difficulty)


#----------------------EXPORTED VARIABLES----------------------
@export var difficultyName1: String = "Normal"
@export var difficultyName2: String = "Hard"
@export var difficultyName3: String = "Very Hard"
@export var difficultyName4: String = "Horror"
@export var levelsRef: Node3D
@export var templeSpritesArray: Array[Texture2D]
@export var arrowSpriteArray: Array[Texture2D]
@export var hoveredSpriteArray: Array[Texture2D]
@export var pressedSpriteArray: Array[Texture2D]
@export var videoArray: Array[VideoStream]
@export var discriptionArray: Array[String]
@export var yokaiArray: Array[Texture2D]
@export var arenaFrame: Array[Texture2D]
@export var arenaFrameDecoration: Array[Texture2D]
@export var arenaName: Array[String]
@export var arenaBackgrounds: Array[Texture2D]


#----------------------VARIABLES----------------------
var UI
var currentDifficulty = 0
var difficultyDict = {
	0: difficultyName1,
	1: difficultyName2,
	2: difficultyName3,
	3: difficultyName4
}
var difficultydiscriptionArray: Array[String] = ["None", "+20%", "+40%", "+60%"]
var spawnratediscriptionArray: Array[String] = ["None", "+50%", "+100%", "+150%"]

@onready var checkmarkDict = {
	0: $ArenaSettingsArea/CheckmarkContainer/Normal_Checkmark,
	1: $ArenaSettingsArea/CheckmarkContainer/Hard_Checkmark,
	2: $ArenaSettingsArea/CheckmarkContainer/VeryHard_Checkmark,
	3: $ArenaSettingsArea/CheckmarkContainer/Horror_Checkmark
}

@onready var yokaiAnimationDict = {
	0: $ArenaSettingsArea/YokaiIconContainer/YokaiIcon/AnimationPlayer,
	1: $ArenaSettingsArea/YokaiIconContainer/YokaiIcon2/AnimationPlayer,
	2: $ArenaSettingsArea/YokaiIconContainer/YokaiIcon3/AnimationPlayer,
	3: $ArenaSettingsArea/YokaiIconContainer/YokaiIcon4/AnimationPlayer
}


#----------------------INITIALIZATION----------------------
# [ ? ] Initializes and plays difficulty animation for default difficulty
func _ready() -> void:
	difficultyAnimation(currentDifficulty)


#----------------------BUTTON HANDLERS----------------------
# [ ? ] Emits signal to start the game with selected difficulty
func onStartButtonPressed() -> void:
	startGame.emit(currentDifficulty)
	UI.buttonClick.play()


# [ ? ] Lowers the difficulty level and updates UI
func onReduceDifficultyButtonPressed() -> void:
	if (currentDifficulty > 0):
		currentDifficulty -= 1
	UI.buttonClick.play()
	difficultyAnimation(currentDifficulty)
	$ArenaSettingsArea/DifficultyDisplay/DifficultyFrame/DifficultyLabel.text = difficultyDict[currentDifficulty]


# [ ? ] Increases the difficulty level and updates UI
func onIncreaseDifficultyButtonPressed() -> void:
	if (currentDifficulty < len(difficultyDict) - 1):
		currentDifficulty += 1
	UI.buttonClick.play()
	difficultyAnimation(currentDifficulty)
	$ArenaSettingsArea/DifficultyDisplay/DifficultyFrame/DifficultyLabel.text = difficultyDict[currentDifficulty]


# [ ? ] Returns the current selected difficulty
func getCurrentDifficulty():
	return currentDifficulty


# [ ? ] Emits signal to restart the game with current difficulty
func onGameRetryGame() -> void:
	startGame.emit(currentDifficulty)
	UI.buttonClick.play()


# [ ? ] Emits signal to go back to arena selection screen and resets difficulty
func onBackButtonPressed() -> void:
	changeToArenaSelectionScreen.emit()
	UI.buttonClick.play()
	currentDifficulty = 0
	difficultyAnimation(currentDifficulty)
	$ArenaSettingsArea/DifficultyDisplay/DifficultyFrame/DifficultyLabel.text = difficultyDict[currentDifficulty]


#----------------------ANIMATIONS----------------------
# [ ? ] Plays the appropriate animation based on the selected difficulty and updates description text
func difficultyAnimation(difficulty):
	for animationplayer in yokaiAnimationDict:
		yokaiAnimationDict[animationplayer].stop()
	yokaiAnimationDict[difficulty].play("Wobbel")
	$ArenaSettingsArea/SettingsStyleFrame/SettingsDescriptionText.text = "Enemybonus \nHealth: " + difficultydiscriptionArray[difficulty] + "\nMovement: " + difficultydiscriptionArray[difficulty] + "\nDamage: " + difficultydiscriptionArray[difficulty] + "\nSpawnrate: " + spawnratediscriptionArray[difficulty]


#----------------------ARENA SETTINGS----------------------
# [ ? ] Sets all arena-specific sprites, video, description, and icons based on selected index
func setSprites(Index: int):
	$ArenaSettingsArea/SettingsStyleFrame.texture = templeSpritesArray[Index]
	$ArenaSettingsArea/DifficultyDisplay/ReduceDifficultyBtn.texture_normal = arrowSpriteArray[Index]
	$ArenaSettingsArea/DifficultyDisplay/ReduceDifficultyBtn.texture_pressed = pressedSpriteArray[Index]
	$ArenaSettingsArea/DifficultyDisplay/ReduceDifficultyBtn.texture_hover = hoveredSpriteArray[Index]
	$ArenaSettingsArea/DifficultyDisplay/IncreaseDifficultyBtn.texture_normal = arrowSpriteArray[Index]
	$ArenaSettingsArea/DifficultyDisplay/IncreaseDifficultyBtn.texture_pressed = pressedSpriteArray[Index]
	$ArenaSettingsArea/DifficultyDisplay/IncreaseDifficultyBtn.texture_hover = hoveredSpriteArray[Index]
	$ArenaDescriptionArea/VideoStreamPlayer.stream = videoArray[Index]
	$ArenaDescriptionArea/VideoStreamPlayer.play()
	$ArenaDescriptionArea/ArenaDescriptionText.text = discriptionArray[Index]
	for sprites in $ArenaSettingsArea/YokaiIconContainer.get_children():
		sprites.texture = yokaiArray[Index]
	for checkmark in levelsRef.completedDict[Index]:
		checkmarkDict[checkmark].visible = levelsRef.completedDict[Index][checkmark]
	$ArenaDescriptionArea/ArenaDescriptionBGImage.texture = arenaFrame[Index]
	$ArenaTitleSection/ArenaTitleLabel.text = arenaName[Index]
	$BackgroundImagePlaceholder.texture = arenaBackgrounds[Index]
	$ArenaDescriptionArea/ArenaDescriptionBGImage/ArenaFrame.texture = arenaFrameDecoration[Index]
	$"../WinScreen".setFrame(Index)
	$"../FailScreen".setFrame(Index)
	$"../PauseScreen".setFrame(Index)


# [ ? ] Assigns a reference to the UI object for button click sounds and other UI interactions
func setUIObject(UIObject):
	UI = UIObject
