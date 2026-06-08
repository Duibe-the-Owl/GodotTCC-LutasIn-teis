extends Area3D
@export_group("Player Settings")	
@export var player_node : CharacterBody3D

var pão_dialogue_played : bool = false


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not pão_dialogue_played:
		pão_dialogue_played = true
		Dialogic.start("PãoTalk")
