extends Area3D

# Drag your sound file (.wav, .ogg, .mp3) into this slot in the Inspector
@export var interaction_sound : AudioStream 
@onready var mesh_node: MeshInstance3D = get_parent().get_node("Sign")

func interact():
	print("Interacting with: ", get_parent().name)
	if mesh_node and mesh_node.material_overlay is ShaderMaterial:
		mesh_node.material_overlay.set_shader_parameter("color", Color(1, 1, 1, 0))
	# ------------------------------
	$CollisionShape3D.set_deferred("disabled", true)
	
	# Tell the PathFollow to start moving
	get_node("../../BusPath/PathFollow3D").start_bus_event()
	queue_free()
