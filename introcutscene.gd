extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	# Connect the signal that triggers when the video ends
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	# 1. Mark the first day as handled so this never plays again
	GameManager.is_first_day = false
	
	# 2. Change to your main game scene (adjust the path to your actual scene)
	get_tree().change_scene_to_file("res://scenes/Apartamento.tscn")
