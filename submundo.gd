extends Node3D

@export_group("Boulder Settings")
@export var boulder : RigidBody3D
@export var boulder_interaction_area : Area3D
@export var push_speed : float = 2.0
@export var push_direction : Vector3 = Vector3(0, 0.5, -1).normalized() # Adjust to match your hill's slope!
@export var top_of_hill_marker : Marker3D
@export var starting_boulder_position : Marker3D # Place a Marker where the boulder spawns

@export_group("Player Settings")
@export var player : CharacterBody3D
@export var rockOffset : Vector3

# --- NEW: Story & NPC Settings ---
@export_group("NPC & Story Settings")
@export var npc_scene : PackedScene      # Drag and drop your saved NPC .tscn file here!
@export var npc_spawn_point : Marker3D   # Place a Marker3D where the NPC should appear

@export_group("Ending Sequence")
@export var white_fade_rect : ColorRect
@export var next_scene_path : String = "res:FinalApartamento.tscn" # Paste your next scene's file path here

var is_pushing : bool = false
var push_count : int = 0
var current_snap_point : Marker3D

func _ready():
	# Connect the signals from the boulder's Area3D
	if boulder_interaction_area:
		boulder_interaction_area.push_started.connect(_on_push_started)
		boulder_interaction_area.push_stopped.connect(_on_push_stopped)
		
	# 1. SCENE INTRO: Plays immediately when the player spawns into Submundo
	Dialogic.start("submundo_intro") # Replace with your actual intro timeline name
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_push_started(snap_point: Marker3D):
	is_pushing = true
	current_snap_point = snap_point
	
	# Lock player out of normal movement and hide their mesh if needed
	if player:
		player.set_physics_process(false)
		player.global_position = boulder.global_position + rockOffset
		player.face_target(top_of_hill_marker.position)

func _on_push_stopped():
	print("a")
	player.set_physics_process(true)
	player.move_and_slide()
	is_pushing = false

func _physics_process(delta):
	if is_pushing:
		# SAFETY FALLBACK: If the player somehow releases E without triggering the signal
		if not Input.is_action_pressed("interact"):
			_on_push_stopped()
			boulder_interaction_area.stop_pushing() # Tells the boulder to unfreeze
			return # Exit early so it doesn't move this frame
			
		# Otherwise, proceed with moving up the hill...
		var movement = push_direction * push_speed * delta
		boulder.global_position += movement
		
		if player and current_snap_point:
			player.global_position = boulder.global_position + rockOffset
			pass
			
		if boulder.global_position.distance_to(top_of_hill_marker.global_position) < 5.0:
			_on_reached_top()
	else:
		player.velocity += Vector3.UP * -10 * delta

func _on_reached_top():
	# 1. Turn off the movement engine
	is_pushing = false 
	boulder_interaction_area.is_being_pushed = false
	boulder_interaction_area.stop_pushing()
	_on_push_stopped() 
	
	push_count += 1
	print("Sisyphus Loop Count: ", push_count, " / 3")
	
	# 2. ALWAYS snap it back to the start marker first
	_reset_boulder_to_start()
	
	# 3. Decide which dialogue/event to play based on the count
	if push_count >= 3:
		# On the 3rd drop, spawn the NPC and play the final interaction
		_spawn_npc_and_finish()
	else:
		# On drops 1 and 2, just play the quick internal dialogue
		Dialogic.start("boulder_drop_" + str(push_count))

func _reset_boulder_to_start():
	boulder.global_position = starting_boulder_position.global_position
	boulder.linear_velocity = Vector3.ZERO 
	boulder.angular_velocity = Vector3.ZERO
	print("Boulder reset! Ready for next push.")

func _spawn_npc_and_finish():
	if npc_scene and npc_spawn_point:
		var npc_instance = npc_scene.instantiate()
		add_child(npc_instance)
		npc_instance.global_position = npc_spawn_point.global_position
	
	# This timeline will now act as your "boulder_drop_3" AND the NPC conversation!
	Dialogic.start("SísifoTalk")
	
func _on_dialogic_signal(argument: String):
	# When the timeline emits our secret word, start the ascension!
	if argument == "ascend_player":
		_start_ending_sequence()

func _start_ending_sequence():
	print("Starting Ascension Sequence!")
	
	# 1. Lock the player so they can't walk around while floating
	if player:
		player.set_physics_process(false)

	# 2. Create a Tween (Godot's code-animation tool)
	var tween = create_tween()
	tween.set_parallel(true) # Make both animations happen at the exact same time

	# 3. Lift the player up (Moves them up 10 units over 5 seconds)
	if player:
		tween.tween_property(player, "global_position:y", player.global_position.y + 10.0, 5.0)

	# 4. Fade the screen to white (Changes Alpha to 1.0 over 5 seconds)
	if white_fade_rect:
		tween.tween_property(white_fade_rect, "modulate:a", 1.0, 5.0)

	# 5. When the 5 seconds are over, run the scene change function
	tween.chain().tween_callback(_change_to_next_scene)

func _change_to_next_scene():
	# Loads the next level
	get_tree().change_scene_to_file(next_scene_path)
