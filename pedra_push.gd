extends Area3D

signal push_started
signal push_stopped

@export var boulder_body : RigidBody3D
@export var snap_point : Marker3D
@export var boulder_mesh : MeshInstance3D
@export var rotation_speed : float = 1.0

var is_being_pushed = false

func interact():
	# This function is called by your player's "Press E" raycast
	is_being_pushed = true
	
	# Freeze physics so the boulder doesn't roll over the player while they push
	boulder_body.freeze = true 
	
	push_started.emit(snap_point)

func _process(delta):
	if is_being_pushed:
		# The boulder checks the keyboard directly!
		if Input.is_action_just_released("interact"):
			stop_pushing()
		
		if boulder_mesh:
			boulder_mesh.rotate_object_local(Vector3.RIGHT, rotation_speed * delta)
			
func stop_pushing():
	is_being_pushed = false
	
	# Unfreeze physics so it realistically rolls backward down the hill!
	boulder_body.freeze = false 
	boulder_body.linear_velocity = Vector3.ZERO
	boulder_body.angular_velocity = Vector3.ZERO

	push_stopped.emit()
