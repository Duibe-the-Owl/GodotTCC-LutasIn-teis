extends Node3D

# Export this so you can click and select your game's main gameplay/level scene
@export_file("*.tscn") var gameplay_scene_path: String

@onready var play_button: Button = $MainMenu/MenuButtons/PlayButton

@onready var menu_buttons: VBoxContainer = $MainMenu/MenuButtons
@onready var options_window: PanelContainer = $MainMenu/OptionsWindow

@onready var music_slider: HSlider = $MainMenu/OptionsWindow/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $MainMenu/OptionsWindow/VBoxContainer/SFXSlider

@onready var text_window: PanelContainer = $MainMenu/AboutWindow

var music_bus_index: int
var sfx_bus_index: int

func _ready() -> void:
	
	# Ensure the mouse is fully visible and usable when arriving at the main menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	menu_buttons.show()
	options_window.hide()
	text_window.hide()
	
	# Fetch audio buses
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	if music_bus_index == -1: music_bus_index = AudioServer.get_bus_index("Master")
	if sfx_bus_index == -1: sfx_bus_index = AudioServer.get_bus_index("Master")
	
	_sync_sliders_with_audio_server()

func _sync_sliders_with_audio_server() -> void:
	var music_db = AudioServer.get_bus_volume_db(music_bus_index)
	music_slider.value = db_to_linear(music_db)
	
	var sfx_db = AudioServer.get_bus_volume_db(sfx_bus_index)
	sfx_slider.value = db_to_linear(sfx_db)

# --- Main Buttons ---

func _on_play_button_pressed() -> void:
	if gameplay_scene_path != "":
		GameManager.fresh_game_started = true
		SceneManager.transition_to(gameplay_scene_path)
	else:
		push_error("Main Menu Error: You forgot to assign a Gameplay Scene Path in the Inspector!")

func _on_options_button_pressed() -> void:
	menu_buttons.hide()
	options_window.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

# --- Shared Options Submenu Controls ---

func _on_back_button_pressed() -> void:
	options_window.hide()
	menu_buttons.show()

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus_index, value == 0.0)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_index, value == 0.0)
	
func _on_about_button_pressed() -> void:
	# Hide the main menu buttons, open the text window
	menu_buttons.hide()
	text_window.show()
	
func _on_text_back_button_pressed() -> void:
	# Hide the text window, bring back the main menu buttons
	text_window.hide()
	menu_buttons.show()
