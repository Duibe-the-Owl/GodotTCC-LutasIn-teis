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
		# CHANGE "Wave" TO THE EXACT NAME IN YOUR ANIMATION TREE GRAPH
		npc_playback.travel("Talk_Porteiro")
		
func _on_dialogic_signal(argument: String):
	if argument == "talk_porteiro":
		npc_playback.travel("Talk_Porteiro")
