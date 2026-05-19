extends CanvasLayer

var player: CharacterBody3D

func _ready() -> void:
	hide()
	player = get_tree().get_first_node_in_group("Player")

func _on_resume_button_pressed() -> void:
	if player and player.has_method("unpause_game"):
		player.unpause_game()
	else:
		# Fallback if pause menu is tested alone
		get_tree().paused = false
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_options_button_pressed() -> void:
	print("Options menu clicked")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
