extends Area3D

# Drag your spawn Marker3D into this slot in the Inspector!
@export var spawn_point : Marker3D 

func _ready() -> void:
	# Automatically connect the body_entered signal to our function
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check if the object that fell into the zone belongs to the "player" group
	if body.is_in_group("player"):
		print("Player fell out of bounds! Teleporting...")
		
		if spawn_point:
			# 1. Instantly move the player to the spawn marker
			body.global_position = spawn_point.global_position
			
			# 2. CRITICAL PHYSICS FIX: Clear the player's falling velocity!
			# If we don't do this, they will keep their downward momentum and slam into the floor.
			if "velocity" in body:
				body.velocity = Vector3.ZERO
