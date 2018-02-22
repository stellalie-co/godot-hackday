extends Node2D

# REQUIRED - name of current weapon

func start_attacking():
	pass


func stop_attacking():
	pass


func destroy():
	stop_attacking()
	queue_free()