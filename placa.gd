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
