extends Control

# Drag and drop your submundo.tscn file into this inspector slot, 
# or type the path manually.
@export_file("*.tscn") var final_scene_path : String = "res://submundo.tscn" 

func _ready():
	# 1. Wait a moment for the scene manager's fade-in overlay to finish settling down
	await get_tree().create_timer(1.0).timeout
	
	print("Void scene active. Starting text...")
	
	# 2. Fire up the dialogue directly over the black background
	Dialogic.start("Night3DreamTalk")
	
	# 3. Safely wait for the player to click through all of the text
	await Dialogic.timeline_ended
	
	print("Dialogue finished. Moving to the final world scene...")
	
	# 4. Now that the script is alive and safe inside the current scene, 
	# we can smoothly transition to the submundo map!
	SceneManager.transition_to(final_scene_path, null, true)
