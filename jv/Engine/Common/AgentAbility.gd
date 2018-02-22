extends Node2D

# EXPORT ==============================
export(bool) var disabled = false setget set_disabled, get_disabled
export(bool) var debug = false setget , get_debug


# VARIABLE ============================
var controller
var agent
var sound_manager
var target_groups


func _ready():
	target_groups = get_controller().get_target_groups()
	
	if disabled:
		set_process(false)
		set_physics_process(false)

func set_disabled(value):
	disabled = value

	if disabled:
		set_process(false)
		set_physics_process(false)


func get_target_groups():
	return target_groups


func get_controller():
	if !controller:
		controller = get_parent()
	return controller
	

func get_agent():
	if !agent:
		agent = get_controller().get_agent()
	return agent


func get_disabled():
	return disabled

func play_sound(name):
	if sound_manager:
		sound_manager.play(name)

func get_debug():
	return OS.is_debug_build() and debug