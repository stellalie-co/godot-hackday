# jv-godot/Common/BaseController
extends Node2D

# EXPORT ==============================
# REQUIRED
export(String) var damagable_groups = ""

# OPTIONAL
export(NodePath) var agent_torso

# OPTIONAL
export(NodePath) var agent_animation

# OPTIONAL
export(NodePath) var agent_shape

# OPTIONAL
export(bool) var display_debug_information = false


# SIGNAL =============================
signal status_updated(status, options)


# CONSTANT =============================
const AnimationAdapter = preload("res://jv/Engine/Helper/AnimationAdapter.gd")

# CACHING =============================
onready var debug = OS.is_debug_build() and display_debug_information


# VARIABLE ============================

var agent_data = {}
# main agent instance
var agent
var a_animation
var a_torso
var a_shape
var target_groups


func get_target_groups():
	if !target_groups:
		target_groups = damagable_groups.split(",")
	return target_groups


func get_agent():
	if !agent:
		agent = get_owner()
	return agent


func get_agent_torso():
	if !a_torso:
		if agent_torso:
			a_torso = get_node(agent_torso)
		else:
			a_torso = get_node("..")
	return a_torso
	

func get_agent_shape():
	if !a_shape:
		if agent_shape:
			a_shape = get_node(agent_shape)
		else:
			a_shape = get_node("../../agent_shape")
	return a_shape


func get_agent_animation():
	if !a_animation:
		var anim
		if agent_animation:
			anim = get_node(agent_animation)
		else:
			anim = get_node("../agent_animation")
		a_animation = AnimationAdapter.new()
		a_animation.set_animation_instance(anim)

	return a_animation
	

func set_agent_animation_identifier(identifier):
	var a_anim = get_agent_animation()
	if a_anim:
		a_anim.set_identifier(identifier)


func set_agent_animation_modifier(modifier):
	var a_anim = get_agent_animation()
	if a_anim:
		a_anim.set_modifier(modifier)


func play_agent_animation(animation_state = null, ignore_modifier = false):
	var a_anim = get_agent_animation()
	if a_anim:
		return a_anim.play(animation_state, ignore_modifier)

	return false
	
func play_agent_animation_once(animation_state = null, ignore_modifier = false, animation_on_finished = "idle"):
	var a_anim = get_agent_animation()
	if a_anim:
		return a_anim.play_once(animation_state, ignore_modifier, animation_on_finished)
	return false


func dispatch_after_animation(animation_state, instance, callback_name):
	var a_anim = get_agent_animation()
	if a_anim:
		a_anim.dispatch_after_animation(animation_state, instance, callback_name)


func listen_for_status_updated(instance, callback_name):
	connect("status_updated", instance, callback_name)


func broadcast_status(status, options = {}):
	emit_signal("status_updated", status, options)


func get_agent_data(key):
	if agent_data.has(key):
		return agent_data[key]
	return null


func set_agent_data(key, value):
	agent_data[key] = value


func unset_agent_data(key):
	agent_data.erase(key)
	
	
func print_debug_information(info):
	if debug:
		print(info)