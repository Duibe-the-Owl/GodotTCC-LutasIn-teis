extends CanvasLayer

var player: CharacterBody3D

# UI Container references
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var options_window: PanelContainer = $OptionsWindow

# Slider references
@onready var music_slider: HSlider = $OptionsWindow/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $OptionsWindow/VBoxContainer/SFXSlider

# Audio bus indices
var music_bus_index: int
var sfx_bus_index: int

func _ready() -> void:
	hide()
	options_window.hide()
	menu_buttons.show()
	
	# Find the player in our scene
	player = get_tree().get_first_node_in_group("Player")
	
	# Get the audio channels from Godot's AudioServer
	# (Ensure these match the exact names in your "Audio" tab at the bottom of Godot!)
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	# If you haven't set up custom buses yet, fallback to Master for safety
	if music_bus_index == -1: music_bus_index = AudioServer.get_bus_index("Master")
	if sfx_bus_index == -1: sfx_bus_index = AudioServer.get_bus_index("Master")
	
	# Initialize slider visual positions to match actual game volume
	_set_slider_initial_values()

func _set_slider_initial_values() -> void:
	var music_db = AudioServer.get_bus_volume_db(music_bus_index)
	music_slider.value = db_to_linear(music_db)
	
	var sfx_db = AudioServer.get_bus_volume_db(sfx_bus_index)
	sfx_slider.value = db_to_linear(sfx_db)

# --- Core Buttons ---

func _on_resume_button_pressed() -> void:
	if player and player.has_method("unpause_game"):
		player.unpause_game()
	else:
		get_tree().paused = false
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_options_button_pressed() -> void:
	# Hide main buttons, open the options window
	menu_buttons.hide()
	options_window.show()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.transition_to("res://main_menu.tscn")

# --- Options Window Controls ---

func _on_back_button_pressed() -> void:
	# Save changes / return to main menu buttons
	options_window.hide()
	menu_buttons.show()

func _on_music_slider_value_changed(value: float) -> void:
	# Convert slider value (0.0 to 1.0) into logarithmic audio Decibels (-60db to 0db)
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
	# Completely mute the channel if slider is all the way down
	AudioServer.set_bus_mute(music_bus_index, value == 0.0)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_index, value == 0.0)
