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

var is_pushing : bool = false
var push_count : int = 0
var current_snap_point : Marker3D

func _ready():
	# Connect the signals from the boulder's Area3D
	if boulder_interaction_area:
		boulder_interaction_area.push_started.connect(_on_push_started)
		boulder_interaction_area.push_stopped.connect(_on_push_stopped)

func _on_push_started(snap_point: Marker3D):
	is_pushing = true
	current_snap_point = snap_point
	
	# Lock player out of normal movement and hide their mesh if needed
	if player:
		player.set_physics_process(false)
		# Optional: player.global_position = snap_point.global_position
		# Optional: player.global_rotation = snap_point.global_rotation

func _on_push_stopped():
	is_pushing = false
	# Re-enable player controls when they let go of E
	if player:
		player.set_physics_process(true)

func _physics_process(delta):
	if is_pushing:
		# 1. Manually move the boulder up the hill axis
		boulder.global_position += push_direction * push_speed * delta
		
		# 2. Keep the player locked to the boulder's snap point while moving
		if player and current_snap_point:
			player.global_position = current_snap_point.global_position
			
		# 3. Check if we reached the top of the hill
		if boulder.global_position.distance_to(top_of_hill_marker.global_position) < 2.0:
			_on_reached_top()

func _on_reached_top():
	_on_push_stopped() # Force the interaction to break
	boulder_interaction_area.is_being_pushed = false
	
	push_count += 1
	print("Boulder reached the top! Count: ", push_count)
	
	if push_count >= 3:
		# INTERRUPT WITH DIALOGIC
		boulder.freeze = true # Lock it in place so it doesn't roll away during the talking
		Dialogic.start("sisyphus_boulder_timeline") # Replace with your Dialogic timeline name
	else:
		# Let physics take over so it rolls back down on its own!
		boulder.freeze = false 
		
		# Set up a check to wait until it settles back at the bottom, or manually reset it
		await get_tree().create_timer(5.0).timeout # Give it 5 seconds to roll down
		_reset_boulder_to_start()

func _reset_boulder_to_start():
	boulder.freeze = true # Freeze it again so it stays put
	boulder.global_position = starting_boulder_position.global_position
	boulder.linear_velocity = Vector3.ZERO # Cancel out any leftover physics momentum
	boulder.angular_velocity = Vector3.ZERO
	
	# Re-enable the interaction area so they can push it again
	boulder_interaction_area.process_mode = PROCESS_MODE_INHERIT
