extends Node3D

@onready var monitor = $MainCarteira/DeskUnit/Monitor/Area3D  # Updated to Area3D based on your setup
@onready var animator = $MainCarteira/DeskUnit/AnimationPlayer
@onready var sit_camera = $MainCarteira/DeskUnit/CutsceneCamera
@onready var player = $Player 

# Points exactly to your ScreenInteractionArea node
@onready var scribble_area = $MainCarteira/DeskUnit/ScreenInteractionArea

var is_playing_cutscene = false

func _ready():
	monitor.player_sat_down.connect(_on_monitor_interacted)
	
	if scribble_area:
		scribble_area.process_mode = PROCESS_MODE_DISABLED

func _on_monitor_interacted():
	if is_playing_cutscene:
		return
	
	is_playing_cutscene = true
	
	player.hide() 
	player.set_physics_process(false)
	sit_camera.make_current()
	
	animator.play("start_computer")
	await animator.animation_finished 
	
	# Enable the scribble area and reveal the mouse cursor
	if scribble_area:
		scribble_area.process_mode = PROCESS_MODE_INHERIT
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_signature_finished():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.5).timeout
	SceneManager.transition_to("res://escritórioNoite.tscn")
