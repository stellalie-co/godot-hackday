extends Node2D

export(bool) var disabled = false
export(bool) var debug = false
export(int) var cooldown_time = 1
export(String) var skill_animation = ""
export(int) var skill_priority = 0


var activating = false setget , is_activating
var target_groups = []
var skill_slots
var timer


func _ready():
	if cooldown_time > 0:
		timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(cooldown_time)
		timer.connect("timeout", self, "_on_cooldown_timer_timeout")
		
		
func get_skill_slots():
	if !skill_slots:
		skill_slots = get_parent()

	return skill_slots


func get_controller():
	return get_skill_slots().get_controller()
	

func get_agent():
	return get_controller().get_agent()
	
func get_target_groups():
	return get_controller().get_target_groups()


func set_target_groups(groups):
	target_groups = groups
	
func is_activating():
	return activating
	
func get_priority():
	return skill_priority


# Subclass will override this method to decide when the skill can be activated
func can_activate():
	return !disabled and (!timer or timer.is_stopped())


func activate():
	if disabled:
		return

	if can_activate():
#		get_controller().dispatch_after_animation(skill_animation, self, "_on_skill_end")
		perform_skill()
		activating = true
		restart_timer()


func perform_skill():
	pass
	
func restart_timer():
	if timer:
		timer.start()

func _on_skill_end():
	activating = false

func _on_cooldown_timer_timeout():
	timer.stop()
	
func get_debug():
	return debug
