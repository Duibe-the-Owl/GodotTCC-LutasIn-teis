extends Area3D

signal push_started
signal push_stopped

@export var boulder_body : RigidBody3D
@export var snap_point : Marker3D
@export var boulder_mesh : MeshInstance3D
@export var rotation_speed : float = 1.0
@export var push_audio : AudioStreamPlayer3D

var is_being_pushed = false

func interact():
	# This function is called by your player's "Press E" raycast
	is_being_pushed = true
	
	# Freeze physics so the boulder doesn't roll over the player while they push
	boulder_body.freeze = true 
	
	if push_audio and not push_audio.playing:
		push_audio.play()
	
	push_started.emit(snap_point)

func _process(delta):
	if is_being_pushed:
		# The boulder checks the keyboard directly!
		if Input.is_action_just_released("interact"):
			stop_pushing()
		
		if boulder_mesh:
			boulder_mesh.rotate_object_local(Vector3.RIGHT, rotation_speed * delta)
			
	# --- NEW: Dynamic Physics Audio Controller ---
	if boulder_body and push_audio:
		# The boulder should make noise if:
		# 1. The player is actively pushing it OR 
		# 2. The physics velocity length is greater than a tiny threshold (it's rolling on its own)
		var is_rolling : bool = is_being_pushed or (boulder_body.linear_velocity.length() > 0.1)
		
		if is_rolling:
			if not push_audio.playing:
				push_audio.play()
		else:
			if push_audio.playing:
				push_audio.stop()
			
func stop_pushing():
	is_being_pushed = false
	
	# Unfreeze physics so it realistically rolls backward down the hill!
	boulder_body.freeze = false 
	boulder_body.linear_velocity = Vector3.ZERO
	boulder_body.angular_velocity = Vector3.ZERO

	push_stopped.emit()
