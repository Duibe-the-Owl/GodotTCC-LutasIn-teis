extends Camera3D

# Drag your ColorRect (the one with the shader) into this slot in the inspector
@export var shader_rect: ColorRect

func _process(_delta: float) -> void:
	if shader_rect and shader_rect.material:
		# Grab the camera's global rotation angles (pitch and yaw)
		var cam_rot := Vector2(global_transform.basis.get_euler().x, global_transform.basis.get_euler().y)
		
		# Send those angles directly into the shader's uniform variable
		shader_rect.material.set_shader_parameter("camera_rotation", cam_rot)
