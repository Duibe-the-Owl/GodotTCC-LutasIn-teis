extends Node3D

@export var tv_animator : AnimationPlayer
@export var tv_camera : Camera3D
@export_group("Player Settings")	
@export var player_node : CharacterBody3D
@export var remote_control : Area3D

var wardrobe_dialogue_played : bool = false

func _ready():
	SceneManager.handle_scene_entrance()
	if remote_control:
		remote_control.player_sat_down.connect(_on_tv_started)

func _on_tv_started():
	# 1. Visual Prep: Hide the player to prevent mesh clipping
	if player_node:
		player_node.hide()
		player_node.set_physics_process(false)
	
	# 2. Camera Swap: Take over the view
	if tv_camera:
		tv_camera.make_current()
	
	# 3. Animation: Start the TV cutscene timeline
	if tv_animator:
		tv_animator.play("start_tv")


# --- SCENE-AWARE KEYFRAME TIMELINE TRIGGER ---
func trigger_tv_timeline(part_suffix: Variant = ""):
	var current_scene = get_tree().current_scene.name
	var suffix = str(part_suffix).strip_edges()
	
	print("🔍 TV KEYFRAME ALIVE! Current scene: '", current_scene, "', Arg: '", suffix, "'")
	
	if Dialogic.current_timeline != null:
		print("⚠️ TV WARNING: Dialogic was already playing: '", Dialogic.current_timeline.resource_path, "'")
	
	# 1. Restore scene differentiation logic (Channel1 / Channel2 / Channel3)
	var base_channel = ""
	match current_scene:
		"ApartamentoNoite":
			base_channel = "Channel1"
		"ApartamentoNoite2":
			base_channel = "Channel2"
		"ApartamentoNoite3":
			base_channel = "Channel3"
		_:
			print("Warning: TV turned on in unhandled scene: ", current_scene)
			base_channel = "Channel1"

	# 2. Build final timeline name (handles plain calls, suffixes, or custom timeline overrides)
	var target_timeline = base_channel
	if suffix != "":
		if suffix.begins_with("_") or suffix.begins_with("Part"):
			target_timeline = base_channel + "_" + suffix.lstrip("_")
		elif suffix.begins_with("Channel"):
			target_timeline = suffix # Explicit timeline override from keyframe
		else:
			target_timeline = base_channel + "_" + suffix

	print("▶️ Starting Dialogic timeline: '", target_timeline, "'")
	Dialogic.start(target_timeline)
	
	# 3. Force auto-advance for TV dialogues
	var aa = Dialogic.Inputs.auto_advance
	if aa:
		aa.set("enabled", true)
		aa.set("fixed_delay", 3.0)


# Compatibility function in case your Call Method track calls play_single_tv_timeline directly
func play_single_tv_timeline(incoming_argument: Variant = ""):
	trigger_tv_timeline(incoming_argument)


# --- RESTORE PLAYER (CALL THIS ON THE FINAL KEYFRAME OF YOUR TV ANIMATION) ---
func _restore_player():
	print("--- TV animation complete: Restoring player control ---")
	if player_node:
		player_node.show()
		var p_cam = player_node.get_node_or_null("Camera3D")
		if p_cam:
			p_cam.make_current()
		player_node.set_physics_process(true)


# Wardrobe Interaction Logic
func _on_area_3d_body_entered(body: Node3D):
	if body.name == "Player" and not wardrobe_dialogue_played:
		wardrobe_dialogue_played = true
		
		var current_scene_name = get_tree().current_scene.name
		
		if current_scene_name == "ApartamentoDia2":
			Dialogic.start("SecondWardrobe")
		elif current_scene_name == "ApartamentoDia3":
			Dialogic.start("ThirdWardrobe")
		elif current_scene_name == "FinalApartamento":
			Dialogic.start("FinalWardrobe")
		else:
			Dialogic.start("WardrobeTalk")
