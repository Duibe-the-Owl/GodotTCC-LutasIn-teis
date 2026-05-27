extends Area3D

@onready var viewport = $/root/escritório/ComputerCanvas/SubViewportContainer/SubViewport
@onready var screen_mesh = $/root/escritório/MainCarteira/DeskUnit/Screen

func _ready():
	input_event.connect(_input_event)

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
