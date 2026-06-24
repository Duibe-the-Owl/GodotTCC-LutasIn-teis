extends Area3D

signal push_started
signal push_stopped

@export var boulder_body : RigidBody3D
@export var snap_point : Marker3D
@export var boulder_mesh : MeshInstance3D
@export var rotation_speed : float = 1.0
@export var push_audio : AudioStreamPlayer3D

var is_being_pushed = false
var interaction_enabled = true 

func interact():
	if not interaction_enabled:
		return
		
	is_being_pushed = true
	boulder_body.freeze = true 
	
	if push_audio and not push_audio.playing:
		push_audio.play()
	
	push_started.emit(snap_point)

func _process(delta):
	if is_being_pushed:
		if Input.is_action_just_released("interact"):
			stop_pushing()
		
		if boulder_mesh:
			boulder_mesh.rotate_object_local(Vector3.RIGHT, rotation_speed * delta)
			
	if boulder_body and push_audio:
		var is_rolling : bool = is_being_pushed or (boulder_body.linear_velocity.length() > 0.1)
		
		if is_rolling:
			if not push_audio.playing:
				push_audio.play()
		else:
			if push_audio.playing:
				push_audio.stop()
			
func stop_pushing():
	is_being_pushed = false
	boulder_body.freeze = false 
	boulder_body.linear_velocity = Vector3.ZERO
	boulder_body.angular_velocity = Vector3.ZERO

	push_stopped.emit()

# --- NEW: Complete Cleanup Engine ---
func disable_and_cleanup_boulder():
	interaction_enabled = false
	monitoring = false
	monitorable = false
	
	# 1. Disable all collision shapes inside this area. 
	# This instantly breaks the player's raycast, forcing the E prompt UI to disappear!
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = true
			
	# 2. Force stop the grinding audio loop
	if push_audio:
		push_audio.stop()
		
	# 3. Strip away the outline mesh or shader material
	if boulder_mesh:
		# Method A: If your outline is a "Next Pass" on a Material Override
		if boulder_mesh.material_override and boulder_mesh.material_override.next_pass:
			boulder_mesh.material_override.next_pass = null
			
		# Method B: If your outline is a "Next Pass" on the base material slot 0
		elif boulder_mesh.get_active_material(0) and boulder_mesh.get_active_material(0).next_pass:
			boulder_mesh.get_active_material(0).next_pass = null
			
		# Method C: If your outline is an entirely separate MeshInstance3D child node (e.g., named "Outline")
		# Un-comment the lines below if this matches your setup!
		# var outline_mesh = boulder_mesh.get_node_or_null("Outline")
		# if outline_mesh:
		#     outline_mesh.hide()
