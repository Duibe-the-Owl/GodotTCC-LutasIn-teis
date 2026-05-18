extends Area3D

# --- NEW: Drag your Door (StaticBody3D) into this slot in the Inspector ---
@export var target_door : Node3D 

# Drag your sound file (.wav, .ogg, .mp3) into this slot in the Inspector
@export var interaction_sound : AudioStream 

func interact():
	print("Interacting with: ", get_parent().name)
	
	# 1. UNLOCK THE DOOR
	if target_door:
		if target_door.has_method("unlock"):
			target_door.unlock()
			print("Door unlocked successfully!")
		else:
			print("Error: The door node doesn't have an 'unlock' function.")
	else:
		print("Warning: No target_door assigned to this key in the Inspector.")

	# 2. VISUALS AND COLLISION
	# Hide the MeshInstance (the parent)
	if get_parent():
		get_parent().hide()
	
	# Disable collision so the RayCast stops hitting it immediately
	$CollisionShape3D.set_deferred("disabled", true)
	
	# 3. SOUND (Optional - if you want to play the sound before deleting)
	# If you want to play a sound, we usually don't queue_free immediately.
	# For now, we'll just delete it like before:
	get_parent().queue_free()
	
	var arrow = get_node_or_null("/root/Apartamento/Móveis (Quarto)/ObjectiveArrow")
	if arrow:
		arrow.complete_objective()
		
	queue_free()
