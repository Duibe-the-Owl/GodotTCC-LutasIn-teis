extends Control

@export var document_textures: Array[Texture2D] = []

@onready var desktop_bg = $DesktopBackground
@onready var paper_container = $PaperContainer
@onready var paper_bg = $PaperContainer/PaperBackground
@onready var action_button = $ActionButton

var current_page_index: int = 0
var is_drawing: bool = false
var current_line: Line2D
var ink_color: Color = Color.BLACK
var line_width: float = 4.0
var center_x: float = 0.0

# Store ink lines here so they slide *with* the paper container
var active_lines: Array[Line2D] = []

func _ready():
	center_x = paper_container.position.x
	mouse_filter = Control.MOUSE_FILTER_STOP
	if document_textures.size() > 0:
		paper_bg.texture = document_textures[0]
	
	action_button.pressed.connect(_on_button_pressed)
	_update_button_text()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		print("2D Canvas received a click at local pos: ", event.position) # DIAGNOSTIC
	var local_pos = paper_container.make_input_local(event).position
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_drawing(local_pos)
		else:
			stop_drawing()
			
	elif event is InputEventMouseMotion and is_drawing:
		add_stroke_point(local_pos)

func start_drawing(start_pos: Vector2):
	is_drawing = true
	current_line = Line2D.new()
	current_line.default_color = ink_color
	current_line.width = line_width
	current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Add the line to the container so it moves with the paper!
	paper_container.add_child(current_line)
	active_lines.append(current_line)
	current_line.add_point(start_pos)

func add_stroke_point(current_pos: Vector2):
	if current_line:
		if current_line.points.size() == 0 || current_line.points[-1].distance_to(current_pos) > 2.0:
			current_line.add_point(current_pos)

func stop_drawing():
	is_drawing = false
	current_line = null

# --- SLIDING ANIMATION LOGIC ---

func _on_button_pressed():
	# Disable the button temporarily so the player can't spam it during the animation
	action_button.disabled = true
	
	if current_page_index < document_textures.size() - 1:
		animate_page_transition()
	else:
		# Last page finished
		var world_scene = get_tree().current_scene
		if world_scene.has_method("_on_signature_finished"):
			world_scene._on_signature_finished()

func animate_page_transition():
	var tween = create_tween().set_parallel(false)
	
	# Dynamically grab the current width of the viewport/screen
	var screen_width = get_viewport_rect().size.x
	
	# Calculate safe off-screen positions relative to your center
	var offscreen_left = center_x - screen_width
	var offscreen_right = center_x + screen_width
	
	# 1. Slide the current signed paper off to the left dynamically
	tween.tween_property(paper_container, "position:x", offscreen_left, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# 2. When it's fully off-screen, swap data instantly
	tween.tween_callback(func():
		current_page_index += 1
		clear_signature()
		paper_bg.texture = document_textures[current_page_index]
		_update_button_text()
		
		# Instantly teleport the paper to the dynamic far RIGHT side
		paper_container.position.x = offscreen_right
	)
	
	# 3. Slide the new fresh paper back into the EXACT captured center
	tween.tween_property(paper_container, "position:x", center_x, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 4. Re-enable the button when the animation is completely done
	tween.tween_callback(func(): action_button.disabled = false)

func clear_signature():
	for line in active_lines:
		if is_instance_valid(line):
			line.queue_free()
	active_lines.clear()

func _update_button_text():
	if current_page_index == document_textures.size() - 1:
		action_button.text = "Finish"
	else:
		action_button.text = "Next Page"
