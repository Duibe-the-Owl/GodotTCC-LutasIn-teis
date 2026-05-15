extends Node3D

@onready var monitor = $MainCarteira/DeskUnit/Monitor/StaticBody3D
@onready var animator = $MainCarteira/DeskUnit/AnimationPlayer
@onready var sit_camera = $MainCarteira/DeskUnit/CutsceneCamera
@onready var player = $Player 

var is_playing_cutscene = false

func _ready():
	# Connect the monitor signal to a local function
	monitor.player_sat_down.connect(_on_monitor_interacted)

func _on_monitor_interacted():
	if is_playing_cutscene:
		return
	
	is_playing_cutscene = true
	
	# 1. Prep the visuals
	player.hide() 
	player.set_physics_process(false)
	sit_camera.make_current()
	
	# 2. Play the sitting & video animation
	animator.play("start_computer")
	
	# 3. Wait for the cutscene to finish
	await animator.animation_finished	
	
	# 4. Give the player a second to process the end of the video
	await get_tree().create_timer(0.5).timeout
	
	# 5. TRIGGER THE SCENE CHANGE
	# This calls your existing SceneManager to do the heavy lifting
	SceneManager.transition_to("res://escritórioNoite.tscn")
	
	# Note: We don't need to show the player or switch cameras here 
	# because the whole scene is about to be deleted/swapped!
