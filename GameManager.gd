extends Node

var current_day: int = 1
var fresh_game_started : bool = false

func advance_day():
	current_day += 1
	# Logic to transition back to the bedroom
