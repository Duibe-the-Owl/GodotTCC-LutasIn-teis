extends Area3D

signal push_started
signal push_stopped

@export var boulder_body : RigidBody3D
@export var snap_point : Marker3D
@export var boulder_mesh : MeshInstance3D
@export var rotation_speed : float = 5.0

var is_being_pushed = false

func interact():
	# This function is called by your player's "Press E" raycast
	is_being_pushed = true
	
	# Freeze physics so the boulder doesn't roll over the player while they push
	boulder_body.freeze = true 
	
	push_started.emit(snap_point)

func _process(delta):
	if is_being_pushed:
		if Input.is_action_just_released("interact"):
			stop_pushing()
		
		# Rotate the mesh visually since physics rotation is frozen!
		if boulder_mesh:
			boulder_mesh.rotate_y(rotation_speed * delta)
			
func stop_pushing():
	is_being_pushed = false
	
	# Unfreeze physics so it realistically rolls backward down the hill!
	boulder_body.freeze = false 
	
	push_stopped.emit()
