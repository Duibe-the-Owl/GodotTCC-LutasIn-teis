extends Area3D

@export var npc_node : Node3D 
var npc_playback
var has_triggered = false

func _ready():
	if npc_node:
		var anim_tree = npc_node.get_node_or_null("AnimationTree")
		if anim_tree:
			npc_playback = anim_tree.get("parameters/playback")
	else:
		print("Warning: No NPC assigned to Area3D!")

	# --- THE MISSING LINK ---
	# This wires Dialogic directly to the _on_dialogic_signal function below
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_body_entered(body):
	if (body.name == "Player" or body.is_in_group("Player")) and not has_triggered:
		has_triggered = true
		var player_node = body 
		if player_node.has_method("face_target"):
			player_node.face_target(npc_node.global_position)
		start_dialogue()

func start_dialogue():
	Dialogic.start("PortariaTalk")
	if npc_playback:
		npc_playback.travel("Talk_Porteiro")
		
func _on_dialogic_signal(argument: String):
	if argument == "talk_porteiro":
		if npc_playback:
			npc_playback.travel("Talk_Porteiro")
	if argument == "end_dialogue":
		if npc_playback:
			# This will now successfully fire when the timeline hits the end event
			npc_playback.travel("Idle_Porteiro")
