extends Control


#----------------------SIGNALS----------------------
signal changeToTitleScreen
signal playSFXSound
signal changeToPauseScreen


#----------------------VARIABLES----------------------
var UI
@export var startMusicVolume: int = 20
@export var startSFXVolume: int = 20
@export var maxMusicVolume: int = 100
@export var maxSFXVolume: int = 100
var musicBus: String = "music"
var soundEffectsBus: String = "soundEffects"
var busIndexMusic: int
var busIndexSFX: int
@onready var backSignals : Array[Signal] = [changeToTitleScreen, changeToPauseScreen]
var backSignalIndex


#----------------------READY FUNCTION----------------------
# [ ? ] Initializes the volume settings and passes bus index values
func _ready() -> void:
	passIndexValues()
	setStartVolumeValues(startMusicVolume, startSFXVolume)


#----------------------BUTTON PRESSES----------------------
# [ ? ] Emits signal when back button is pressed and plays button click sound
func onBackBtnPressed() -> void:
	backSignals[backSignalIndex].emit()
	UI.buttonClick.play()


#----------------------SLIDER CHANGE HANDLERS----------------------
# [ ? ] Updates the music volume when the music volume slider is changed
func onVolumeSliderValueChanged(value: float) -> void:
	setAudioBusValue(busIndexMusic, value)


# [ ? ] Updates the sound effects volume when the SFX volume slider is changed
func onSoundEffectsSliderValueChanged(value: float) -> void:
	setAudioBusValue(busIndexSFX, value)


#----------------------VOLUME SETTINGS----------------------
# [ ? ] Sets the starting values for music and SFX volume and updates sliders
func setStartVolumeValues(musicValue, sfxValue):
	setAudioBusValue(busIndexMusic, musicValue)
	setAudioBusValue(busIndexSFX, sfxValue)
	setSliderValues(maxMusicVolume, maxSFXVolume, startMusicVolume, startSFXVolume)


# [ ? ] Retrieves the audio bus index for music and sound effects
func passIndexValues():
	busIndexMusic = AudioServer.get_bus_index(musicBus)
	busIndexSFX = AudioServer.get_bus_index(soundEffectsBus)


# [ ? ] Sets the volume of the audio bus
func setAudioBusValue(busIndex, value):
	AudioServer.set_bus_volume_db(
		busIndex,
		linear_to_db(value)
	)


# [ ? ] Sets the maximum values and starting values for sliders
func setSliderValues(maxValueMusic, maxValueSFX, startingValueMusic, startingValueSound):
	$Panel/VerticalOptionContainer/OptionFrame_Music/SettingFrame/musicVolumeSlider.max_value = maxValueMusic
	$Panel/VerticalOptionContainer/OptionFrame_SFX/SettingFrame/soundEffectsVolumeSlider.max_value = maxValueSFX
	$Panel/VerticalOptionContainer/OptionFrame_Music/SettingFrame/musicVolumeSlider.value = startingValueMusic
	$Panel/VerticalOptionContainer/OptionFrame_SFX/SettingFrame/soundEffectsVolumeSlider.value = startingValueSound


#----------------------SFX HANDLER----------------------
# [ ? ] Emits SFX signal when sound effects volume slider drag ends
func onSoundEffectsVolumeSliderDragEnded(value_changed: bool) -> void:
	playSFXSound.emit()


#----------------------UI OBJECT SETTER----------------------
# [ ? ] Sets the UI object for later use
func setUIObject(UIObject):
	self.UI = UIObject
