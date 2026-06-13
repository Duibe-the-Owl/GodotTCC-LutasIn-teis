extends Area3D

# We switch from @onready to normal variables so we can define them dynamically in _ready()
var viewport: SubViewport
var screen_mesh: MeshInstance3D # Or Node3D, depending on your type

func _ready():
	input_event.connect(_input_event)
	
	# 1. Get the exact name of whichever world node is currently active
	var scene_name = get_tree().current_scene.name
	
	# 2. Dynamically build the absolute paths using that scene name
	var viewport_path = "/root/" + scene_name + "/ComputerCanvas/SubViewportContainer/SubViewport"
	var screen_path = "/root/" + scene_name + "/MainCarteira/DeskUnit/Screen"
	
	# 3. Safely fetch the nodes
	viewport = get_node_or_null(viewport_path)
	screen_mesh = get_node_or_null(screen_path)
	
	# Quick safety check in case a path typo happens down the line
	if not viewport:
		print("Warning: Could not find Viewport at: ", viewport_path)
	if not screen_mesh:
		print("Warning: Could not find Screen Mesh at: ", screen_path)

func _input_event(_camera: Camera3D, event: InputEvent, shape_position: Vector3, _normal: Vector3, _shape_idx: int):
	if not viewport:
		return
		
	if event is InputEventMouseButton and event.pressed:
		print("3D Hitbox clicked at global position: ", shape_position) # DIAGNOSTIC
		
		var event_copy = event.duplicate()
		var local_point = to_local(shape_position)
		var box_size = $CollisionShape3D.shape.size
		
		var uv = Vector2(
			(local_point.x / box_size.x) + 0.5,
			0.5 - (local_point.y / box_size.y) 
		)
		
		var viewport_size = viewport.size
		event_copy.position = Vector2(uv.x * viewport_size.x, uv.y * viewport_size.y)
		
		if "global_position" in event_copy:
			event_copy.global_position = event_copy.position
			
		print("Sending 2D coordinates to Viewport: ", event_copy.position) # DIAGNOSTIC
		viewport.push_input(event_copy)
