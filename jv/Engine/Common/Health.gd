# jv-godot/Common/Health
extends Node2D

# EXPORT ==============================
export(int) var max_health = 100
export(int) var current_health = 100
# OPTIONAL - the lower the number the faster the agent can be hit again
export(float) var invincible_time_on_hit = 0.1
# OPTIONAL
export(bool) var god_mode = false


var is_alive = true setget , get_is_alive
var invincible = false
var agent
var controller
var timer
var current_animation_state


func _ready():
	# caching
	controller = get_parent()
	agent = controller.get_agent()
	
	# attach new metadata function to agent which will dispatch when he got hit
	agent.set_meta("receive_damage", funcref(self, "agent_receive_damage"))
	
	if current_health <= 0:
		current_health = 1
		
	if invincible_time_on_hit > 0:
		timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(invincible_time_on_hit)
		timer.connect("timeout", self, "_on_invincible_timer_timeout")
	
	controller.listen_for_status_updated(self, "_on_status_updated")


func get_is_alive():
	return is_alive

func agent_receive_damage(damage, options = {}):
	decrease_health_points(damage)


func increase_health_points(health_points):
	if is_alive:
		health_points = abs(health_points)
		current_health += health_points
		
		if current_health > max_health:
			current_health = max_health
		return true
	return false


func decrease_health_points(health_points):
	if !is_alive:
		return false

	if invincible:
		return false

	if !god_mode:
		health_points = abs(health_points)
		current_health -= health_points

	if current_health < 0:
		current_health = 0

	# Damage agent
	if current_health > 0:
		controller.play_agent_animation_once("hit", true, current_animation_state)
		controller.broadcast_status("hit")
		restart_invincible_timer()
	# Kill agent
	else:
		var agent_shape = controller.get_agent_shape()
		is_alive = false
		controller.dispatch_after_animation("die", self, "kill_agent")
		
		if agent_shape:
			agent_shape.set_disabled(true)
		agent.set_process(false)
#		agent.set_physics_process(false)

	return true


func kill_agent():
	agent.queue_free()


func restart_invincible_timer():
	if timer:
		timer.start()
		invincible = true

func _on_invincible_timer_timeout():
	timer.stop()
	invincible = false
	controller.broadcast_status("recover_after_hit")
	
func _on_status_updated(status, options):
	if status == "movement":
		current_animation_state = options.state
