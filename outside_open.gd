extends StaticBody3D

# Drag your AnimationPlayer here in the Inspector
@export var anim_player : AnimationPlayer
@export var animation_name : String = "DoorOpen"
@export var interaction_sound : AudioStream 
@export var open_sound : AudioStream 



var is_open : bool = false

func interact():
	if anim_player == null:
		print("Error: No AnimationPlayer assigned to the door!")
		return
		
	if not anim_player.is_playing():
		if not is_open:
			anim_player.play(animation_name)
			is_open = true
		else:
			anim_player.play_backwards(animation_name)
			is_open = false
			
	if open_sound:
		SceneManager.play_sfx(open_sound)
	process_mode = PROCESS_MODE_DISABLED
