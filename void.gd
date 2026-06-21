extends Control

# Drag and drop your submundo.tscn file into this inspector slot, 
# or type the path manually.
@export_file("*.tscn") var final_scene_path : String = "res://submundo.tscn"

func _ready():
	# 1. Wait a moment for the scene manager's fade-in overlay to finish settling down
	await get_tree().create_timer(1.0).timeout
	print("Void scene active. Starting text...")
	Dialogic.start("Night3DreamTalk")
	await Dialogic.timeline_ended	
	print("Dialogue finished. Moving to the final world scene...")
	SceneManager.transition_to(final_scene_path, null, true)
