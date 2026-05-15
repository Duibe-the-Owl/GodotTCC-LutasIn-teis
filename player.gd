extends CharacterBody3D

@export_group("Movement")
@export var speed = 4.0
@export var acceleration = 8.0
@export var friction = 20.0 

@export_group("Mouse Look")
@export var mouse_sensitivity = 0.001
@export var mouse_smoothing = 10.0
@export var y_sensitivity_multiplier = 0.7 

@export_group("Head Bob")
@export var bob_freq = 2.4
@export var bob_amp = 0.05
var t_bob = 0.0

@export_group("Dynamic FOV")
@export var base_fov = 75.0
@export var fov_change = 1.5

@export_group("Audio")
@export var default_footstep_sound : AudioStream # Drag your sound file here!
@onready var foot_audio = $FootstepPlayer 
@onready var interaction_audio = $InteractionAudioPlayer

@export_group("Interaction")
@export var interaction_time = 1.5 
var current_hold_time = 0.0

@onready var interact_ray = $Camera3D/RayCast3D
@onready var interact_label = $CanvasLayer/Label 
@onready var interact_progress = $CanvasLayer/TextureProgressBar 

var rotation_x = 0.0
var target_rotation_x = 0.0
var mouse_input := Vector2.ZERO
var last_bob_sine = 0.0 

@onready var camera = $Camera3D
@onready var initial_camera_height = camera.position.y

var is_in_cutscene = false

@onready var anim_tree = $AnimationTree
@onready var playback = anim_tree.get("parameters/playback")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# This forces the sound into the node at runtime, 
	# overriding whatever the AnimationPlayer did to the inspector slot.
	if default_footstep_sound:
		foot_audio.stream = default_footstep_sound
	if anim_tree:
		anim_tree.active = true

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	rotate_y(-mouse_input.x * mouse_sensitivity)
	target_rotation_x -= mouse_input.y * mouse_sensitivity * y_sensitivity_multiplier
	target_rotation_x = clamp(target_rotation_x, deg_to_rad(-80), deg_to_rad(80))
	rotation_x = lerp(rotation_x, target_rotation_x, mouse_smoothing * delta)
	camera.rotation.x = rotation_x
	mouse_input = Vector2.ZERO

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		
		# ... your existing movement code ...

	if velocity.length() > 0.1:
	# We are moving
		playback.travel("Walk_Nick") 
	else:
	# We are standing still
		playback.travel("Idle_Nick")

	move_and_slide()

	_handle_head_bob(delta)
	_handle_dynamic_fov(delta)
	_handle_interaction(delta)

func _handle_interaction(delta):
	if interact_ray.is_colliding():
		var object = interact_ray.get_collider()
		
		if object and object.has_method("interact"):
			if interact_label: interact_label.show()
			
			if Input.is_action_pressed("interact"):
				# Start/Play sound if the object has one
				if object.get("interaction_sound") and not interaction_audio.playing:
					interaction_audio.stream = object.interaction_sound
					interaction_audio.pitch_scale = randf_range(0.9, 1.1)
					interaction_audio.play()
				
				if interact_progress: interact_progress.show()
				current_hold_time += delta
				
				if interact_progress:
					interact_progress.value = (current_hold_time / interaction_time) * 100
				
				if current_hold_time >= interaction_time:
					object.interact()
					_reset_interaction_ui() # Clean up immediately
					return 
			else:
				_stop_interaction_sound()
				current_hold_time = 0.0
				if interact_progress: interact_progress.hide()
		else:
			_reset_interaction_ui()
	else:
		_reset_interaction_ui()

func _reset_interaction_ui():
	if interact_label: interact_label.hide()
	if interact_progress: interact_progress.hide()
	_stop_interaction_sound()
	current_hold_time = 0.0

func _stop_interaction_sound():
	if interaction_audio.playing:
		interaction_audio.stop()

# ... (Rest of your head bob and FOV functions stay the same)
func _handle_head_bob(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	if is_on_floor() and input_dir != Vector2.ZERO and horizontal_speed > 0.5:
		t_bob += delta * horizontal_speed * bob_freq
	else:
		t_bob = lerp(t_bob, 0.0, delta * 10.0)
		
		# --- THE FIX IS HERE ---
		# Only stop the audio if we are NOT in a cutscene.
		# This prevents the script from killing the AnimationPlayer's sounds.
		if foot_audio.playing and not is_in_cutscene:
			foot_audio.stop()
	
	var bob_sine = sin(t_bob)
	var bob_cosine = cos(t_bob * 0.5)
	var current_amp = bob_amp if (input_dir != Vector2.ZERO and horizontal_speed > 0.5) else 0.0
	
	var target_y = initial_camera_height + (bob_sine * current_amp)
	var target_x = (bob_cosine * current_amp * 0.5)
	
	camera.transform.origin.y = lerp(camera.transform.origin.y, target_y, delta * 10.0)
	camera.transform.origin.x = lerp(camera.transform.origin.x, target_x, delta * 10.0)

	if is_on_floor() and input_dir != Vector2.ZERO:
		if bob_sine < 0.0 and last_bob_sine >= 0.0:
			_play_footstep()
	
	last_bob_sine = bob_sine

func _handle_dynamic_fov(delta):
	var target_fov = base_fov + (fov_change * velocity.length())
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func _play_footstep():
	if foot_audio:
		foot_audio.stop() 
		foot_audio.pitch_scale = randf_range(0.92, 1.08)
		foot_audio.play()

func start_intro_sequence():
	is_in_cutscene = true
	anim_tree.active = false
	# Assuming your AnimationPlayer is named 'anim_player'
	$AnimationPlayer.play("intro_get_up")
	
	# Wait for the animation to finish before giving control back
	await $AnimationPlayer.animation_finished
	is_in_cutscene=false
	anim_tree.active = true

func _force_stop_footsteps():
	if foot_audio.playing:
		foot_audio.stop()


@onready var anim_player = $AnimationPlayer

func trigger_dialogue():
	Dialogic.start("StartCutscene")
	
func face_target(target_pos: Vector3):
	var look_pos = Vector3(target_pos.x, global_position.y, target_pos.z)
	var target_transform = transform.looking_at(look_pos, Vector3.UP)
	var target_rotation_y = target_transform.basis.get_euler().y
	
	# We use a tween to rotate the body smoothly
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation_y, 0.8).set_trans(Tween.TRANS_SINE)
	
	# THE FIX: Ensure these are always floats (0.0) and not Nil
	target_rotation_x = 0.0 
	rotation_x = 0.0
	# Reset mouse input so the camera doesn't "jump" after the turn
	mouse_input = Vector2.ZERO
