extends Node3D

@onready var animator = $MainCarteira/DeskUnit/AnimationPlayer
@onready var video_player = $MainCarteira/DeskUnit/Screen/SubViewport/VideoStreamPlayer

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

# 1. This starts the movement when you press 'E'
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
		
func trigger_custom_dialogue():
	print("--- DEBUG: Keyframe hit! Starting Dialogic timeline now ---")
	Dialogic.start("ComputerTalk")


func _on_dialogic_signal(argument: String):
	match argument:
		"pause_video":
			video_player.set_paused(true)
		"resume_video":
			video_player.set_paused(false)
		"stop_video":
			video_player.stop()
