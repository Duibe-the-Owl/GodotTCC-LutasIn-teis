extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var rect = $ColorRect
@onready var sfx = $AudioStreamPlayer3D

# This will control exactly when the intro is allowed to play
var should_trigger_intro = true

func _ready():
	rect.modulate.a = 1 # Start black
	handle_scene_entrance()

func handle_scene_entrance():
	var current_scene_name = get_tree().current_scene.name
	print("Entered scene: ", current_scene_name)
	print("Should trigger intro status: ", should_trigger_intro)
	
	# Create a list of all scenes that are allowed to play the waking up intro
	var allowed_intro_scenes = ["Apartamento", "ApartamentoDia2", "ApartamentoDia3", "FinalApartamento"]
	
	# Check if the current scene name is anywhere inside our list
	if should_trigger_intro and current_scene_name in allowed_intro_scenes:
		should_trigger_intro = false # Turn it off immediately so it doesn't loop
		
		var player = get_tree().get_root().find_child("Player", true, false)
		if player and player.has_method("start_intro_sequence"):
			print("Player found! Kicking off waking up cutscene...")
			player.start_intro_sequence()
			anim.play("fade_to_normal")
		else:
			print("Warning: Intro conditions met, but Player or method wasn't found. Fading in.")
			anim.play("fade_to_normal")
	else:
		# If we are entering a normal scene or walking between rooms,
		# we make sure the intro flag is down and just fade in.
		should_trigger_intro = false 
		print("Normal scene entrance. Fading in.")
		anim.play("fade_to_normal")

# --- TRANSITION FUNCTIONS ---

func transition_to(path: String, sound: AudioStream = null, is_bed_transition: bool = false):
	if sound:
		sfx.stream = sound
		sfx.play()
		
	anim.play("fade_to_black")
	await anim.animation_finished
	
	# If we are going to bed, we explicitly request the intro for the next scene
	if is_bed_transition:
		should_trigger_intro = true
	else:
		should_trigger_intro = false
	
	get_tree().change_scene_to_file(path)
	
	await get_tree().process_frame
	handle_scene_entrance()

func play_sfx(sound: AudioStream):
	if sfx != null and sound != null:
		sfx.stream = sound
		sfx.play()

func fadefromblack():
	anim.play("fade_to_normal")
