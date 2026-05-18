extends Area3D

@export var target_scene_path: String
@export var interaction_sound: AudioStream # This lets you pick the sound in the Inspector

@onready var sound_player = $InteractionSound # Reference to the child node

var has_triggered = false

func _ready():
	# Connect the body entered signal to our function below
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if (body.name == "Player" or body.is_in_group("Player")) and not has_triggered:
		has_triggered = true
		SceneManager.transition_to(target_scene_path, interaction_sound)
		var active_arrow = get_tree().get_first_node_in_group("ObjectiveArrows")
		if active_arrow:
			active_arrow.complete_objective()

		queue_free()
