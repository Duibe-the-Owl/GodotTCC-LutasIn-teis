extends Node3D

@export var tv_animator : AnimationPlayer
@export var tv_camera : Camera3D
@export_group("Player Settings")	
@export var player_node : CharacterBody3D
@export var remote_control : Area3D

var wardrobe_dialogue_played : bool = false

func _ready():
	# Connect the remote's signal to this script
	if remote_control:
		remote_control.player_sat_down.connect(_on_tv_started)
	else:
		push_error("Remote Control Area3D not assigned to World Script!")
		
func _on_tv_started():
	# 1. Visual Prep: Hide the player to prevent mesh clipping
	if player_node:
		player_node.hide()
		player_node.set_physics_process(false)
	
	# 2. Camera Swap: Take over the view
	if tv_camera:
		tv_camera.make_current()
	
	# 3. Animation: Start the TV and camera movement
	if tv_animator:
		tv_animator.play("start_tv") # Ensure this matches your TV animation name
		await tv_animator.animation_finished
	
	# 4. Wait & Reset: Give the player control back after it's over
	await get_tree().create_timer(1.0).timeout
	
	_restore_player()
	
func _restore_player():
	if player_node:
		player_node.show()
		# Make sure the path to your player's internal camera is correct
		var p_cam = player_node.get_node_or_null("Camera3D")
		if p_cam:
			p_cam.make_current()
		player_node.set_physics_process(true)

# Make sure the name here matches the one in your Node signal tab!
func _on_area_3d_body_entered(body: Node3D):
	if body.name == "Player" and not wardrobe_dialogue_played:
		wardrobe_dialogue_played = true
		Dialogic.start("WardrobeTalk")
