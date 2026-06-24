extends Control

@export_file("*.tscn") var title_screen_path : String = "res://titlescene.tscn" 

func _ready():
	await get_tree().create_timer(1.0).timeout
	
	# Start the final black screen dialogue
	Dialogic.start("FinalOutroTalk")
	
	# Wait for the player to click through it entirely
	await Dialogic.timeline_ended
	
	# Go back to your title screen
	SceneManager.transition_to("res://titlescene.tscn", null, true)
