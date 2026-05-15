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
# This variable holds the shader material we just made
@export var outline_material : ShaderMaterial

func show_outline():
	if get_parent() is MeshInstance3D:
		get_parent().material_overlay = outline_material
	elif get_parent() is CSGBox3D:
		get_parent().material_overlay = outline_material

func hide_outline():
	if get_parent():
		get_parent().material_overlay = null
