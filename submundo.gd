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
		player.global_position = boulder.global_position + rockOffset
		player.face_target(top_of_hill_marker.position)
		# Optional: player.global_position = snap_point.global_position
		# Optional: player.global_rotation = snap_point.global_rotation

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
			#player.global_transform.basis = Basis(Vector3.UP, current_snap_point.global_transform.basis.get_euler().y)
			#var tempBasis = Basis()
			#tempBasis = tempBasis.looking_at(top_of_hill_marker.position)
			#player.global_transform.basis = tempBasis
			#print(player.rotation)
			player.global_position = boulder.global_position + rockOffset
			pass
			
		if boulder.global_position.distance_to(top_of_hill_marker.global_position) < 2.0:
			_on_reached_top()
	else:
		player.velocity += Vector3.UP * -10 * delta

func _on_reached_top():
	# 1. IMMEDIATELY turn off the movement engine so it stops climbing!
	is_pushing = false 
	
	# 2. Force the interaction scripts to break their states
	boulder_interaction_area.is_being_pushed = false
	boulder_interaction_area.stop_pushing()
	_on_push_stopped() 
	
	push_count += 1
	print("Sisyphus Loop Count: ", push_count, " / 3")
	
	if push_count >= 3:
		# VICTORY: Stop the rock completely and start Dialogic!
		boulder.freeze = true 
		Dialogic.start("sisyphus_boulder_timeline") 
	else:
		# RESET SEQUENCE: Let physics drop it back down
		boulder.freeze = false 
		
		# Turn off the interaction zone temporarily so the player 
		# can't grab it while it's mid-roll
		boulder_interaction_area.process_mode = PROCESS_MODE_DISABLED
		
		# Wait 5 seconds for the boulder to finish rolling down the hill naturally
		await get_tree().create_timer(5.0).timeout 
		
		# Snap it back to the exact start marker to clean up any messy physics drifting
		_reset_boulder_to_start()

func _reset_boulder_to_start():
	boulder.freeze = true # Freeze it so it stays still at the bottom
	boulder.global_position = starting_boulder_position.global_position
	
	# Completely wipe out any residual momentum from the roll down
	boulder.linear_velocity = Vector3.ZERO 
	boulder.angular_velocity = Vector3.ZERO
	
	# Turn the interaction back on! The player can now push lap #2 or #3
	boulder_interaction_area.process_mode = PROCESS_MODE_INHERIT
	print("Boulder reset! Ready for next push.")
