extends Area3D

# The path to the scene you want to load (e.g., "res://scenes/next_day.tscn")
@export_file("*.tscn") var target_scene_path : String
# Optional: A snoring or "yawn" sound effect
@export var sleep_sound : AudioStream
@onready var collision_shape_3d = $CollisionShape3D

func interact():
	print("Going to sleep...")
	
	if target_scene_path == "":
		print("Error: No target scene assigned to the bed!")
		return
		
	collision_shape_3d.set_deferred("disabled", true)
	# Use the transition function we built earlier!
	# This handles the fade out, the sound, the scene change, and the fade in.
	SceneManager.transition_to(target_scene_path, sleep_sound)
