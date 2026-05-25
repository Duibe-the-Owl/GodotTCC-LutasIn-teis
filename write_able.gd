extends Area3D

@onready var viewport = $/root/escritório/MainCarteira/DeskUnit/Screen/SubViewport

func _ready():
	input_event.connect(_on_input_event)

func _on_input_event(_camera: Camera3D, event: InputEvent, _shape_position: Vector3, _normal: Vector3, _shape_idx: int):
	if viewport:
		# Sends the clicks and mouse movement straight to the paper script
		viewport.push_input(event)
