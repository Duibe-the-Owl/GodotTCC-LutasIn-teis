extends Node

var current_day: int = 1
var fresh_game_started : bool = false

func advance_day() -> void:
	if current_day < 3:
		current_day += 1
		print("Day advanced to: ", current_day)
	else:
		print("The loop has finished or reached day 3.")

func go_to_sleep():
	GameManager.advance_day()
	get_tree().change_scene_to_file("res://Apartamento.tscn")

func interact():
	print("--- DIALOGUE TRIGGERED ---")
	print("Godot GameManager Day is: ", GameManager.current_day)
	
	# Force-sync the variable to Dialogic right here to be absolutely sure
	Dialogic.VAR.set_value("current_day", GameManager.current_day)
	print("Dialogic thinks Day is: ", Dialogic.VAR.get_value("current_day"))
	
	Dialogic.start("YourTimelineName")
