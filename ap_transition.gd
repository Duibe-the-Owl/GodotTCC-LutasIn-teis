extends Area3D

@export var target_scene_path: String
@export var interaction_sound: AudioStream # This lets you pick the sound in the Inspector

@onready var sound_player = $InteractionSound # Reference to the child node

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Pass both the path AND the sound resource
		SceneManager.transition_to(target_scene_path, interaction_sound)
