extends Node3D

# Drag your 3 objective items into this list inside the Inspector (in order!)
@export var objectives : Array[Node3D] = []

var current_target : Node3D = null

func _ready():
	_update_target()

func _process(_delta):
	# If we have a valid target, rotate the wrapper to face it
	if is_instance_valid(current_target):
		var target_pos = Vector3(current_target.global_position.x, global_position.y, current_target.global_position.z)
		
		# Prevent errors if the player stands directly on the item
		if global_position.distance_to(target_pos) > 0.2:
			look_at(target_pos, Vector3.UP)
	else:
		# No targets left! Hide the arrow entirely
		hide()

# Call this function whenever an objective item is completed!
func complete_objective():
	if objectives.size() > 0:
		objectives.remove_at(0) # Remove the finished item from the front of the list
		_update_target()

func _update_target():
	if objectives.size() > 0:
		current_target = objectives[0] # Set the next item as the current tracking target
		show()
		global_position = current_target.global_position + Vector3(0, 0.5, 0)
	else:
		current_target = null
		hide()
