extends Area3D

# Type the exact name of your Dialogic timeline here
@export var timeline_name: String = "MesaTalk"
var mesa_dialogue_played : bool = false


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not mesa_dialogue_played:
		mesa_dialogue_played = true
		Dialogic.start("MesaTalk") 
