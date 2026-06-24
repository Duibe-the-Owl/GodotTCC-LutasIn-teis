extends Node3D

@onready var animator = $MainCarteira/DeskUnit/AnimationPlayer
@onready var video_player = $MainCarteira/DeskUnit/Screen/SubViewport/VideoStreamPlayer

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	# Detects the exact millisecond the video naturally stops playing
	video_player.finished.connect(_on_video_finished)


func _on_monitor_interaction_area_player_sat_down():
	if has_node("Player"):
		$Player.hide()
		$Player.set_physics_process(false)
	
	print("--- DEBUG STEP 1: Starting animation 'sit_video' ---")
	animator.play("sit_video")


# 2. THE FIX: The animation timeline will call this function directly at the end frame!
func _on_sit_animation_finished_trigger():
	print("--- DEBUG STEP 3: Timeline reached the end! Starting video now ---")
	
	if video_player != null:
		video_player.play()
		print("--- DEBUG STEP 4: video_player.play() called successfully ---")
	else:
		push_error("CRITICAL: video_player node path is null!")
		
func trigger_timeline(timeline_name: String):
	print("🔍 KEYFRAME ALIVE! Godot is literally passing: '", timeline_name, "'")
	
	# Safety check: Is Dialogic already running something else?
	if Dialogic.current_timeline != null:
		print("⚠️ WARNING: Dialogic was already playing: '", Dialogic.current_timeline.resource_path, "'")
	
	Dialogic.start(timeline_name)

func _on_dialogic_signal(argument: String):
	match argument:
		"pause_video":
			video_player.set_paused(true)
		"resume_video":
			video_player.set_paused(false)
		"stop_video":
			video_player.stop()

func transition_to_next_scene():
	print("--- Triggering transition to escritórioNoite3 ---")
	
	# THE FIX: Force Dialogic to drop everything and close instantly 
	# passing 'true' cuts off the hidden fading delays entirely
	if Dialogic.current_timeline != null:
		Dialogic.end_timeline(true)
	
	var next_scene_path = "res://escritórioNoite3.tscn"
	
	if ResourceLoader.exists(next_scene_path):
		SceneManager.transition_to(next_scene_path)
	else:
		push_error("CRITICAL: Cannot find the scene file at: " + next_scene_path)
		
func _on_video_finished():
	print("The video ran out of frames! Forcing clean up...")
	# Put your scene transition or next step here!
	transition_to_next_scene()
