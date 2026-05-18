extends Node3D

@export var objectives : Array[Node3D] = []
var current_target : Node3D = null
var player : Node3D = null

func _ready():
	# Find your player node to calculate the initial safe angle
	player = get_node_or_null("/root/Apartamento/Player")
	_update_target()

func _process(_delta):
	if is_instance_valid(current_target):
		var target_pos = current_target.global_position
		
		# Now the look_at math is 100% stable because global_position never moves at runtime!
		if global_position.distance_to(target_pos) > 0.1:
			look_at(target_pos, Vector3.UP)
	else:
		hide()

func complete_objective():
	# --- THE INSTANT CLEAR FIX ---
	# We immediately make the current target null and hide the arrow
	current_target = null
	hide()
	
	if objectives.size() > 0:
		objectives.remove_at(0)
		
		# If that was the last item, we stop right here
		if objectives.size() == 0:
			return
			
		# If there are more items left, update to the next one
		_update_target()

func _update_target():
	if objectives.size() > 0:
		current_target = objectives[0]
		show()
		
		var target_pos = current_target.global_position
		
		if is_instance_valid(player):
			var dir_to_player = (player.global_position - target_pos).normalized()
			dir_to_player.y = 0.0
			dir_to_player = dir_to_player.normalized()
			
			# ALTERE AQUI: Mudando de 1.2 para 0.5 (meio metro acima do item)
			global_position = target_pos + Vector3(0, 0.9, 0) + (dir_to_player * 0.25)
		else:
			# Altere aqui também para o caso de fallback
			global_position = target_pos + Vector3(0, 0.9, 0.2)
	else:
		current_target = null
		hide()
