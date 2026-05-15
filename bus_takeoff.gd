extends PathFollow3D

@export var max_speed: float = 5.0
var current_speed: float = 0.0
var should_move: bool = false

# We define them as variables first, then assign them in _ready
var wheel_1: AnimationPlayer
var wheel_2: AnimationPlayer
var wheel_3: AnimationPlayer
var wheel_4: AnimationPlayer
var chassis_player: AnimationPlayer

func _ready():
	# Use find_child to bypass pathing issues and "hidden" instance children
	wheel_1 = find_child("WheelsPlayer1", true, false) as AnimationPlayer
	wheel_2 = find_child("WheelsPlayer2", true, false) as AnimationPlayer
	wheel_3 = find_child("WheelsPlayer3", true, false) as AnimationPlayer
	wheel_4 = find_child("WheelsPlayer4", true, false) as AnimationPlayer
	chassis_player = find_child("AnimationPlayer", true, false) as AnimationPlayer
	
	if wheel_1 == null:
		print("CRITICAL: Wheel 1 still not found via find_child!")
	
	# Small delay to ensure the scene is visible before takeoff
	await get_tree().create_timer(0.1).timeout
	start_bus_event()

func start_bus_event():
	should_move = true
	
	# Start Body Bounce
	if chassis_player and chassis_player.has_animation("BusBounce"):
		chassis_player.play("BusBounce")
		chassis_player.get_animation("BusBounce").loop_mode = Animation.LOOP_LINEAR
	
	# Start Wheel Animations
	if wheel_1: wheel_1.play("WheelLib/spin")
	if wheel_2: wheel_2.play("WheelLib2/spin2")
	if wheel_3: wheel_3.play("WheelLib3/spin3")
	if wheel_4: wheel_4.play("WheelLib4/spin4")

func _process(delta):
	if should_move:
		current_speed = move_toward(current_speed, max_speed, delta * 1.5)
		progress += current_speed * delta
		
		var speed_perc = current_speed / max_speed
		var wheels = [wheel_1, wheel_2, wheel_3, wheel_4]
		
		for w in wheels:
			if w: 
				w.speed_scale = speed_perc
