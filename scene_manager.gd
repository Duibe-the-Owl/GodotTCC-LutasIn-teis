extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var rect = $ColorRect
@onready var sfx = $AudioStreamPlayer3D

var intro_has_played = false

func _ready():
	rect.modulate.a = 1 # Start black
	
	# Check if we are in the Apartamento AND it's the first time
	if not intro_has_played and get_tree().current_scene.name == "Apartamento":
		intro_has_played = true
		_trigger_startup_intro.call_deferred()
	else:
		# If we are just moving between rooms, just fade in normally
		anim.play("fade_to_normal")

func _trigger_startup_intro():
	var player = get_tree().get_root().find_child("Player", true, false)
	
	if player and player.has_method("start_intro_sequence"):
		player.start_intro_sequence()
		anim.play("fade_to_normal")
	else:
		# Safety fallback if player isn't found
		anim.play("fade_to_normal")

# --- TRANSITION FUNCTIONS ---
func transition_to(path: String, sound: AudioStream = null):
	if sound:
		sfx.stream = sound
		sfx.play()
		
	anim.play("fade_to_black")
	await anim.animation_finished
	
	get_tree().change_scene_to_file(path)
	
	anim.play("fade_to_normal")
	# Note: Once the scene changes, the NEW scene's _ready() will fire, 
	# handling the "fade_to_normal" automatically!
	
func play_sfx(sound: AudioStream):
	if sfx != null and sound != null:
		sfx.stream = sound
		sfx.play()
