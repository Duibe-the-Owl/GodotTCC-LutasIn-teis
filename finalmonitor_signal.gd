extends Node3D

@onready var fade_screen = $CanvasLayer/ColorRect # Your fade overlay
# Make sure to adjust these paths to match your actual scene hierarchy:
@onready var player = $Player 
@onready var camera = $Player/Camera3D 

func _ready() -> void:
	# Connect to Dialogic's end signal to automatically trigger the code
	Dialogic.timeline_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended() -> void:
	# Disconnect so it doesn't accidentally run again
	if Dialogic.timeline_ended.is_connected(_on_dialogue_ended):
		Dialogic.timeline_ended.disconnect(_on_dialogue_ended)
	
	start_outro_sequence()

func start_outro_sequence():
	# 1. Lock the player down (Just like sitting at the monitor)
	if player:
		player.set_physics_process(false) 
		# If your player script has an input lock variable, set it here:
		# player.input_locked = true 

	# 2. Calculate the "backing away" target position
	# This takes the camera's current direction and calculates 4 units backward
	var backward_direction = camera.global_transform.basis.z
	var target_position = camera.global_position + (backward_direction * 4.0)

	# 3. Setup the Tween (Set parallel so camera moves AND fades at the same time)
	var outro_tween = create_tween().set_parallel(true)
	
	# Programmatically move the camera backward over 3.5 seconds
	outro_tween.tween_property(camera, "global_position", target_position, 3.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	# Make sure the fade screen is visible and start fading it to black
	fade_screen.visible = true
	fade_screen.modulate.a = 0.0 # Start fully transparent
	outro_tween.tween_property(fade_screen, "modulate:a", 1.0, 3.5)
	
	# 4. Once everything finishes moving and fading, change the scene
	outro_tween.chain().tween_callback(func():
		# Replace this with your actual scene manager transition function!
		SceneManager.transition_to("res://titlescene.tscn")
	)
