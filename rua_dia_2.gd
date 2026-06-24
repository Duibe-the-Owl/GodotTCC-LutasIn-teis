extends Node3D

@export var npc_to_vanish : Node3D
@export var vanish_delay : float = 1.0 

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	if is_instance_valid(npc_to_vanish):
		print("Player looked! Starting countdown...")
		
		# 1. Create a temporary timer and wait for it to finish
		await get_tree().create_timer(vanish_delay).timeout
		
		# 2. CRITICAL SAFETY CHECK: Because we paused for a second, 
		# we must make sure the player didn't leave the room or change scenes during the wait!
		if is_instance_valid(npc_to_vanish):
			print("Time's up! NPC vanishing.")
			npc_to_vanish.queue_free() # Or npc_to_vanish.hide()
