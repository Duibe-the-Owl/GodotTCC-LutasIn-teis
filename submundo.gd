extends Node3D

@export_group("Boulder Settings")
@export var boulder : RigidBody3D
@export var boulder_interaction_area : Area3D
@export var push_speed : float = 2.0
@export var push_direction : Vector3 = Vector3(0, 0.5, -1).normalized() 
@export var top_of_hill_marker : Marker3D
@export var starting_boulder_position : Marker3D 

@export_group("Player Settings")
@export var player : CharacterBody3D
@export var rockOffset : Vector3

@export_group("NPC & Story Settings")
@export var npc_scene : PackedScene      
@export var npc_spawn_point : Marker3D   

@export_group("Ending Sequence")
@export var white_fade_rect : ColorRect
@export_group("Ending Sequence")
@export var next_scene_path : String = "res://FinalApartamento.tscn" 

var is_pushing : bool = false
var push_count : int = 0
var current_snap_point : Marker3D

func _ready():
	if boulder_interaction_area:
		boulder_interaction_area.push_started.connect(_on_push_started)
		boulder_interaction_area.push_stopped.connect(_on_push_stopped)
		
	Dialogic.start("submundo_intro") 
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_push_started(snap_point: Marker3D):
	is_pushing = true
	current_snap_point = snap_point
	
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
		if not Input.is_action_pressed("interact"):
			_on_push_stopped()
			boulder_interaction_area.stop_pushing() 
			return 
			
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
	is_pushing = false 
	boulder_interaction_area.is_being_pushed = false
	boulder_interaction_area.stop_pushing()
	_on_push_stopped() 
	
	push_count += 1
	print("Sisyphus Loop Count: ", push_count, " / 3")
	
	_reset_boulder_to_start()
	
	if push_count >= 3:
		_spawn_npc_and_finish()
	else:
		Dialogic.start("boulder_drop_" + str(push_count))

func _reset_boulder_to_start():
	boulder.global_position = starting_boulder_position.global_position
	boulder.linear_velocity = Vector3.ZERO 
	boulder.angular_velocity = Vector3.ZERO
	print("Boulder reset! Ready for next push.")

func _spawn_npc_and_finish():
	# --- CALL THE CLEANUP ENGINE HERE ---
	if boulder_interaction_area:
		boulder_interaction_area.disable_and_cleanup_boulder()
	
	# Spawn the NPC Sísifo
	if npc_scene and npc_spawn_point:
		var npc_instance = npc_scene.instantiate()
		add_child(npc_instance)
		npc_instance.global_position = npc_spawn_point.global_position
	
	Dialogic.start("SísifoTalk")
	
func _on_dialogic_signal(argument: String):
	if argument == "ascend_player":
		_start_ending_sequence()

func _start_ending_sequence():
	print("Starting Ascension Sequence!")
	
	if player:
		player.set_physics_process(false)

	var tween = create_tween()
	tween.set_parallel(true) 

	if player:
		tween.tween_property(player, "global_position:y", player.global_position.y + 10.0, 5.0)

	if white_fade_rect:
		tween.tween_property(white_fade_rect, "modulate:a", 1.0, 5.0)

	tween.chain().tween_callback(_change_to_next_scene)

func _change_to_next_scene():
	SceneManager.should_trigger_intro = true
	get_tree().change_scene_to_file(next_scene_path)
