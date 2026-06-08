extends Node3D

# Drag your NPC's AnimationTree node into this variable in the inspector!
@export var anim_tree : AnimationTree

# This variable will hold the Tree's State Machine controller
var state_machine : AnimationNodeStateMachinePlayback

func _ready():
	# 1. Grab the state machine from the Animation Tree
	if anim_tree:
		state_machine = anim_tree.get("parameters/playback")
		
	# 2. Connect to Dialogic
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String):
	if not anim_tree or not state_machine:
		return
		
	# 3. Use .travel() to smoothly transition to the new animation state
	if argument == "anim_idle":
		# Make sure "Hold" matches the EXACT name of the node inside your AnimationTree State Machine!
		state_machine.travel("Idle_Sysiphus") 
		
	elif argument == "anim_talk":
		state_machine.travel("Talk_Sysiphus")
		
	elif argument == "anim_hold":
		state_machine.travel("Hold_Sysiphus")
		
	elif argument == "anim_walk":
		state_machine.travel("Walk_Sysiphus")
