extends Node3D

@onready var fade_screen = $CanvasLayer/ColorRect # Your fade overlay
@onready var player = $Player 
@onready var camera = $Player/Camera3D 

func _ready() -> void:
	# Use Dialogic's universal signal listener
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
	# This will only fire when the timeline hits your "start_outro" signal event
	if argument == "start_outro":
		start_outro_sequence()
	
func start_outro_sequence():
	print("Signal received! Starting programmatic camera pull...")
	
	# 1. Lock the player down
	if player:
		player.set_physics_process(false) 

	# 2. Calculate the "backing away" target position
	var backward_direction = camera.global_transform.basis.z
	var target_position = camera.global_position + (backward_direction * 4.0)

	# 3. Setup the Tween
	var outro_tween = create_tween().set_parallel(true)
	
	# Move the camera backward over 3.5 seconds
	outro_tween.tween_property(camera, "global_position", target_position, 3.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	# Fade the screen to black
	fade_screen.visible = true
	fade_screen.modulate.a = 0.0
	outro_tween.tween_property(fade_screen, "modulate:a", 1.0, 3.5)
	
	# 4. Change the scene once the camera pull is completely finished
	outro_tween.chain().tween_callback(func():
		print("Tween finished. Transitioning to outro void...")
		SceneManager.transition_to("res://outrovoid.tscn", null, true)
)
