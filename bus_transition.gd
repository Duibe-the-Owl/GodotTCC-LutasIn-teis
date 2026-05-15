extends Area3D

# This creates the slot in your Inspector for each different bus
@export_file("*.tscn") var destination_scene: String
@export var interaction_sound: AudioStream 

func _on_body_entered(body):
	# Check for both "player" and "Player" just to be safe!
	if body.is_in_group("Player") or body.is_in_group("player"):
		if destination_scene != "":
			# We ONLY call the SceneManager. 
			# It will handle the sound and the jump to the destination_scene.
			SceneManager.transition_to(destination_scene, interaction_sound)
		else:
			push_error("Bus Door Error: You forgot to set the destination_scene in the Inspector!")
