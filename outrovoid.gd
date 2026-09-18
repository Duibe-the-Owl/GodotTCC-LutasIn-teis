extends Control

@export_file("*.tscn") var title_screen_path : String = "res://titlescene.tscn" 
@onready var canvas_layer = $CanvasLayer
@onready var end_image = $EndingCanvas/EndingImage

func _ready():
	if canvas_layer:
		canvas_layer.visible = true
		
	if end_image:
		end_image.visible = true
		end_image.modulate.a = 0.0

	await get_tree().create_timer(1.0).timeout
	
	# Start the final black screen dialogue
	Dialogic.start("FinalOutroTalk")
	
	# Wait for the player to click through it entirely
	await Dialogic.timeline_ended
	
	# Image sequence: Make visible -> Fade IN -> Hold -> Fade OUT
	if end_image:
		end_image.visible = true
		var tween = create_tween()
		tween.tween_property(end_image, "modulate:a", 1.0, 1.5)
		tween.tween_interval(8.0)
		tween.tween_property(end_image, "modulate:a", 0.0, 1.5)
		await tween.finished
	
	# Go back to title screen
	SceneManager.transition_to(title_screen_path, null, true)
