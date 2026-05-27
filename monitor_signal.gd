extends Node3D

@onready var monitor = $MainCarteira/DeskUnit/Monitor/Area3D  # Updated to Area3D based on your setup
@onready var animator = $MainCarteira/DeskUnit/AnimationPlayer
@onready var sit_camera = $MainCarteira/DeskUnit/CutsceneCamera
@onready var player = $Player 

@onready var computer_canvas = $ComputerCanvas
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
	
	# 1. Turn off the "Press E" prompt
	if monitor:
		monitor.process_mode = PROCESS_MODE_DISABLED
	
	# 2. Free the mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 3. Handle player presence and camera transition
	player.hide() 
	player.set_physics_process(false)
	player.is_in_cutscene = true 
	
	sit_camera.make_current()
	animator.play("start_computer")
	
	await animator.animation_finished 
	
	# 4. THE MAGIC TRICK: Pop the 2D computer screen over everything else
	computer_canvas.visible = true
	print("Computer interface overlay is now active and unblockable!")
		
func _on_signature_finished():
	# Hide the unblockable overlay
	computer_canvas.visible = false

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.5).timeout
	
	SceneManager.transition_to("res://escritórioNoite.tscn")
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("The 3D world received a click!")
