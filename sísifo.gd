extends CharacterBody3D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _physics_process(_delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_dir != Vector2.ZERO:
		# Transition to the 'Walk' state in the State Machine
		state_machine.travel("Walk")
	else:
		# Transition back to 'Idle'
		state_machine.travel("Idle")
