extends Area3D

@export_file("*.tscn") var target_scene_path : String
@export var sleep_sound : AudioStream 

@onready var collision_shape_3d = $CollisionShape3D

func interact():
	print("Going to bed...")
	
	if target_scene_path == "":
		print("Error: No target scene assigned!")
		return
	
	# Disable interaction immediately
	collision_shape_3d.set_deferred("disabled", true)
	
	# Pass 'true' as the third argument to trigger the waking up sequence in the next scene
	SceneManager.transition_to(target_scene_path, sleep_sound, true)
	var active_arrow = get_tree().get_first_node_in_group("ObjectiveArrows")
	if active_arrow:
		active_arrow.complete_objective()

		queue_free()
