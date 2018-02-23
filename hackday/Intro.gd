extends Node


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$AnimationSound.play()
	$Animation.play("LogoDrop")
	$Animation.queue("AttackDrop")
	$Animation.queue("LabelDrop")
	$Animation.queue("LabelFlash")
	pass


func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://hackday/CharSelect.tscn")
	pass


func _on_Animation_animation_started(anim_name):
	if (anim_name == "LabelDrop"):
			$AnimationSound.stop()
