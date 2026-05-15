extends PathFollow3D

# --- Variables ---
@export var max_speed: float = 5.0
var current_speed: float = 0.0
var should_move: bool = false
var has_arrived: bool = false

# --- Node References (EXACT NAMES) ---
@onready var chassis_player = $Ônibus/AnimationPlayer 
# Update these to match the names you see in your scene tree exactly!
@onready var wheel_1 = $Ônibus/WheelsPlayer1  # Added the '1'
@onready var wheel_2 = $Ônibus/WheelsPlayer2
@onready var wheel_3 = $Ônibus/WheelsPlayer3
@onready var wheel_4 = $Ônibus/WheelsPlayer4

@onready var all_wheels = [wheel_1, wheel_2, wheel_3, wheel_4]
@onready var engine_audio = $Ônibus/AudioStreamPlayer3D

func start_bus_event():
	should_move = true
	has_arrived = false
	
	if engine_audio:
		if not engine_audio.playing:
			engine_audio.play()
	else:
		print("Audio Error: AudioStreamPlayer3D not found!")

	# 1. Handle the Bus Body Bounce
	if chassis_player:
		# Double-check if the animation is named "BusBounce" 
		# or "LibraryName/BusBounce" in your editor!
		if chassis_player.has_animation("BusBounce"):
			chassis_player.play("BusBounce")
			chassis_player.get_animation("BusBounce").loop_mode = Animation.LOOP_LINEAR
		else:
			print("Missing Animation: Could not find BusBounce. Available: ", chassis_player.get_animation_list())
	else:
		print("Missing Node: chassis_player is not assigned!")

	# 2. Play using your NEW naming convention: Library/Animation
	if wheel_1: wheel_1.play("WheelLib/spin")
	if wheel_2: wheel_2.play("WheelLib2/spin2")
	if wheel_3: wheel_3.play("WheelLib3/spin3")
	if wheel_4: wheel_4.play("WheelLib4/spin4")
	
	# 3. Set Looping for wheels
	var players = [wheel_1, wheel_2, wheel_3, wheel_4]
	var anims = ["WheelLib/spin", "WheelLib2/spin2", "WheelLib3/spin3", "WheelLib4/spin4"]
	
	for i in range(players.size()):
		if players[i] and players[i].has_animation(anims[i]):
			players[i].get_animation(anims[i]).loop_mode = Animation.LOOP_LINEAR

func _process(delta):
	if should_move and not has_arrived:
		current_speed = move_toward(current_speed, max_speed, delta * 2.0)
		progress += current_speed * delta
		
		var speed_perc = current_speed / max_speed
		
		# Added safety checks (if w:) to prevent the 'null instance' crash
		for w in all_wheels:
			if w: 
				w.speed_scale = speed_perc
		
		if chassis_player:
			chassis_player.speed_scale = speed_perc

		if progress_ratio >= 0.99:
			play_bus_stop_events()

func play_bus_stop_events():
	should_move = false
	has_arrived = true
	
	for w in all_wheels:
		w.stop()
	chassis_player.stop()
	chassis_player.speed_scale = 1.0
	
	# Exactly 'BusD_Open' as you mentioned
	if chassis_player.has_animation("BusD_Open"):
		chassis_player.play("BusD_Open")
