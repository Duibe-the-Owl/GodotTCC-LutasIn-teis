extends Area3D

@onready var mesh_node: MeshInstance3D = $".."
# This signal tells the scene 'The player interacted!'
signal player_sat_down

func interact():
	if mesh_node and mesh_node.material_overlay is ShaderMaterial:
		mesh_node.material_overlay.set_shader_parameter("color", Color(1, 1, 1, 0))
	player_sat_down.emit()
	# Disable interaction so they can't spam E during the movie
	process_mode = PROCESS_MODE_DISABLED

	var active_arrow = get_tree().get_first_node_in_group("ObjectiveArrows")
	if active_arrow:
		active_arrow.complete_objective()
		hide()
