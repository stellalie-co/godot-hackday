extends Node


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$Animation.play("LogoDrop")
	$Animation.queue("AttackDrop")
	$Animation.queue("LabelDrop")
	$Animation.queue("LabelFlash")
	pass


func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://hackday/Intro2.tscn")
	pass