extends StaticBody3D

# Drag the AnimationPlayer from your 'PortaSala' node into this slot
@export var anim_player : AnimationPlayer
# Put the exact name of the Blender animation here (e.g. "DoorOpen")
@export var open_animation_name : String = "Door_Open"
@export var open_sound : AudioStream 

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

# The Key script looks for this exact name: "unlock"
func unlock():
	print("Key received! Opening door...")
	
	# 1. Play Blender Animation
	if anim_player:
		anim_player.play(open_animation_name)
	
	# 2. Play Sound via SceneManager
	if open_sound:
		SceneManager.play_sfx(open_sound)
	
	# 3. Disable collision so the player can walk through
	if collision_shape_3d:
		collision_shape_3d.set_deferred("disabled", true)
