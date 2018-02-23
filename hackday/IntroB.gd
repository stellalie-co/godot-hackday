extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$Animation.play("BackgroundFlash")
	$Animation.play("MoveShip")
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://hackday/CharSelect.tscn")
	pass