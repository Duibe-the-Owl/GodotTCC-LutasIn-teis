extends Area3D

# Drag your sound file (.wav, .ogg, .mp3) into this slot in the Inspector
@export var interaction_sound : AudioStream 

func interact():
	print("Interacting with: ", get_parent().name)
	
	# 2. Disable the collision so the RayCast stops hitting it immediately
	# We use set_deferred to avoid errors during physics processing
	$CollisionShape3D.set_deferred("disabled", true)
	
	# Tell the PathFollow to start moving
	get_node("../../BusPath/PathFollow3D").start_bus_event()
	
# This automatically finds the active arrow, no matter what scene it is in!
	var active_arrow = get_tree().get_first_node_in_group("ObjectiveArrows")
	if active_arrow:
		active_arrow.complete_objective()
		hide()
	queue_free()
