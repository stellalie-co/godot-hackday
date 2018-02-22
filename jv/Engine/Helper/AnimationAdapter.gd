# jv-godot/Helper/AnimationAdapter
extends Object

enum TYPE { animatedSprite, animationPlayer }

signal animation_finished(animation)

const HIGH_PRIORITY_ANIMATIONS = ["die"]

var a_instance
var a_type
var a_identifier
var a_state
var a_modifier
var a_storage = {}
var animation = ""
var prefer_animation_on_finished = null
var can_interupt_async_animation = false
var debug = false

func set_animation_instance(instance):
	a_instance = instance
	if a_instance.is_class("AnimatedSprite"):
		a_type = TYPE.animatedSprite	
	elif a_instance.is_class("AnimationPlayer"):
		a_type = TYPE.animationPlayer
		
	a_instance.connect("animation_finished", self, "_on_animation_finished")


func set_identifier(identifier):
	a_identifier = identifier
	play()


func set_modifier(modifier):
	a_modifier = modifier
	play()
	
func play(new_animation = null, ignore_modifier = false):
	if a_instance:
		var animation_to_play = ""
		
		# animation_identifier allow current agent to have a unique prefix like
		# MachineGun-whatever_state_after that so if we combine with other state
		# we can have MachineGun-idle or MachineGun-run
		if a_identifier:
			animation_to_play += a_identifier + "-"
		
		if new_animation:
			animation_to_play += new_animation
			a_state = new_animation
		else:
			animation_to_play += get_animation()

		# it's not necessary to have modifier animation for MachineGun-hit as it's not neccessary to know
		# if current agent is being hit while he's in 45 degree aiming mode
		if a_modifier and !ignore_modifier:
			animation_to_play += "[" + a_modifier + "]"
		# Do not allow any other animation to play while this flag is on
		# except "die"
		if can_interupt_async_animation and HIGH_PRIORITY_ANIMATIONS.find(new_animation) < 0:
			return
		if has_animation(animation_to_play):
			if debug:
				print("animation : " + animation_to_play)
			a_instance.play(animation_to_play)
			animation = animation_to_play
			return true

	return false

func play_once(new_animation = null, ignore_modifier = false, animation_on_finished = "idle"):
	if a_instance:
		prefer_animation_on_finished = animation_on_finished
		return play(new_animation, ignore_modifier)
	return false

func stop():
	a_instance.stop()
	
	
func set_debug(value):
	debug = value


func has_animation(animation_to_check):
	if a_instance:
		if a_type == TYPE.animatedSprite:
			return a_instance.frames.has_animation(animation_to_check)
		elif a_type == TYPE.animationPlayer:
			return a_instance.has_animation(animation_to_check)
	return false
	
func get_animation():
	return animation
	
func dispatch_after_animation(animation, instance, callback_name, can_interupt = true):
	var animation_has_start_to_play = play(animation)
	var callback = funcref(instance, callback_name)

	# dispatch callback after animation has ended
	if animation_has_start_to_play:
		can_interupt_async_animation = can_interupt
		var stored_info = { "instance": instance, "callback": callback }
		if !a_storage.has(animation):
			a_storage[animation] = []

		for stored_data in a_storage[animation]:
			if stored_data["instance"] == instance:
				return

		a_storage[animation].append(stored_info)
	else: # there is no animation to play
		if callback:
			callback.call_func()

func _on_animation_finished(_animation = null):
	var played_animation = get_animation()

	can_interupt_async_animation = false

	if a_storage.has(played_animation):
		for stored_data in a_storage[played_animation]:
			stored_data["callback"].call_func()
		a_storage[played_animation].empty()

	if prefer_animation_on_finished:
		if prefer_animation_on_finished != played_animation:
			play(prefer_animation_on_finished, a_modifier)
			prefer_animation_on_finished = ""