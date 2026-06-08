extends Area3D

# Drag your sound file (.wav, .ogg, .mp3) into this slot in the Inspector
@export var interaction_sound : AudioStream 

func interact():
	print("Interacting with: ", get_parent().name)
	
	# 1. Hide the MeshInstance (the parent)
	if get_parent():
		get_parent().hide()
	
	# 2. Disable the collision so the RayCast stops hitting it immediately
	# We use set_deferred to avoid errors during physics processing
	$CollisionShape3D.set_deferred("disabled", true)

	var arrow = get_node_or_null("/root/Apartamento/Móveis (Quarto)/ObjectiveArrow")
	if arrow:
		arrow.complete_objective()
		
	queue_free()
