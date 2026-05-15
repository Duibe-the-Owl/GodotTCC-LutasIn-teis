extends Area3D

# Replace 'block_path_dialogue' with your actual Timeline name
@export var timeline_name: String = "block_path_dialogue"
var has_triggered: bool = false

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not has_triggered:
		has_triggered = true
		# This searches for a timeline resource named "block_path_dialogue"
		Dialogic.start("TvTalk")

func launch_dialogue() -> void:
	has_triggered = true
	
	# Standard Dialogic 2.x trigger
	Dialogic.start(timeline_name)
	
	# Optional: If you want the dialogue to happen again later, 
	# you could reset has_triggered with a Timer or when the player leaves the area.
