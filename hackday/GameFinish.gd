extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$Animation.play("GraceDefeat")
	$Animation.queue("JohnRunning")