extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$Animation.play("BackgroundFlash")
	$RocketAnimation.play("RocketMove2")
	$RocketAnimation.queue("RocketMove1")
	$RocketAnimation.queue("RocketMove3")
	$Animation.play("JohnRunning")
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://hackday/Intro3.tscn")
	pass