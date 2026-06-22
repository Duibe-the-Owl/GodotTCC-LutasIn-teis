extends Area3D

# Drag and drop your hidden kitchen items group node here from the Inspector
@export var new_kitchen_items: Node3D
@onready var mesh_node: MeshInstance3D = $".."

var has_interacted: bool = false

func interact() -> void:
	if mesh_node and mesh_node.material_overlay is ShaderMaterial:
		mesh_node.material_overlay.set_shader_parameter("color", Color(1, 1, 1, 0))
	
	if has_interacted:
		return
		
	print("Interacting with fridge...")
	has_interacted = true
	
	# 1. Dynamically find the player to lock movement
	var scene_name = get_tree().current_scene.name
	var player = get_node_or_null("/root/" + scene_name + "/Player")
	if player:
		player.set_physics_process(false)
	
	# 2. Create a temporary CanvasLayer and Black Screen
	# We give it a Layer number of 9 so it sits directly UNDER your Layer 10 Dither!
	var temp_canvas = CanvasLayer.new()
	temp_canvas.layer = 9 
	get_tree().current_scene.add_child(temp_canvas)
	
	var black_screen = ColorRect.new()
	black_screen.color = Color.BLACK
	black_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black_screen.modulate.a = 0.0 # Start completely invisible
	temp_canvas.add_child(black_screen)
	
	# 3. Fade to Black (Underneath the dither)
	var fade_out_tween = create_tween()
	await fade_out_tween.tween_property(black_screen, "modulate:a", 1.0, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT).finished
		
	# 4. Swap the items while everything is black
	print("Screen is black (with dither active). Revealing items...")
	if new_kitchen_items:
		new_kitchen_items.visible = true
		
	# Hold on the dark screen for a quick moment
	await get_tree().create_timer(0.4).timeout
	
	# 5. Fade back into the room
	var fade_in_tween = create_tween()
	await fade_in_tween.tween_property(black_screen, "modulate:a", 0.0, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN).finished
	
	# 6. Clean up the temporary nodes and unlock player
	temp_canvas.queue_free()
	
	if player:
		player.set_physics_process(true)
		queue_free()
