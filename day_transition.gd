extends Area3D

@export_file("*.tscn") var target_scene_path : String
@export var sleep_sound : AudioStream 

@onready var collision_shape_3d = $CollisionShape3D

func interact():
	print("Going to bed...")
	
	if target_scene_path == "":
		print("Error: No target scene assigned!")
		return
	
	collision_shape_3d.set_deferred("disabled", true)
	
	var active_arrow = get_tree().get_first_node_in_group("ObjectiveArrows")
	if active_arrow:
		active_arrow.complete_objective()
	
	var current_scene_name = get_tree().current_scene.name
	
	if current_scene_name == "ApartamentoNoite3":
		# Just go straight to the Void Scene. The Void Scene will take it from here!
		SceneManager.transition_to("res://void.tscn", sleep_sound, true)
	else:
		# Standard behavior for Night 1 & 2
		SceneManager.transition_to(target_scene_path, sleep_sound, true)
	
	queue_free()
