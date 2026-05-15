extends Area3D

# This signal tells the scene 'The player interacted!'
signal player_sat_down

func interact():
	# When the player holds E, we trigger the signal
	player_sat_down.emit()
	# Disable interaction so they can't spam E during the movie
	process_mode = PROCESS_MODE_DISABLED
