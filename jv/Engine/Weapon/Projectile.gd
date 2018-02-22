# jv-godot/Weapon/Projectile
extends Area2D


# EXPORT ==============================
export(float) var speed = 400
export(int) var damage = 10
export(bool) var piercing = false
export(int) var life_time = 0
export(NodePath) var hit_animation
export(NodePath) var visibility_notifier_2d


# CONSTANT ============================
const TargetGroup = preload("res://jv/Engine/Common/TargetGroup.gd")


# VARIABLE ============================
var target_groups = []
var visibility_notifier
var flip_horizontal
var direction_guideline
var hit_anim
var index
var total_projectiles
var life_timer


func _ready():
	# Setup life timer
	if life_time > 0:
		life_timer = Timer.new()
		life_timer.set_wait_time(life_time)
		life_timer.one_shot = true
		add_child(life_timer)
		life_timer.connect("timeout", self, "_on_life_timer_timeout")
		life_timer.start()
	
	# Prepare the visibility notifier to detect when object exit screen
	if visibility_notifier_2d:
		visibility_notifier = get_node(visibility_notifier_2d)
	else:
		visibility_notifier = VisibilityNotifier2D.new()
		add_child(visibility_notifier)
	visibility_notifier.connect("screen_exited", self, "_on_screen_exited")
	connect("area_entered", self, "_on_area_entered")
	connect("body_entered", self, "_on_body_entered")
	
	# Cache animation node
	if hit_animation and has_node(hit_animation):
		hit_anim = get_node(hit_animation)
		# handle animation based node
		if hit_anim.has_method("play"):
			hit_anim.connect("animation_finished", self, "_on_hit_animation_finished")
		elif hit_anim.has_method("start"):
			hit_anim.connect("tween_completed", self, "_on_hit_animation_tween_completed")


func set_damage(damage):
	self.damage = damage


func prepare(start_position, flip_horizontal, weapon_rotation, direction_guideline, index, total_projectiles):
	# set initial position
	set_position(start_position)
	
	# flip current weapon if required
	if flip_horizontal:
		scale.x = -1
	else:
		scale.x = 1

	# rotate projectile
	set_rotation_degrees(weapon_rotation)

	# cache required data so subclass can use it to calculate how it should move
	self.flip_horizontal = flip_horizontal
	self.index = index
	self.total_projectiles = total_projectiles
	self.direction_guideline = direction_guideline
	

func set_target_groups(groups):
	target_groups = groups



func _on_area_entered(area):
	validate_then_hit(area)



func _on_body_entered(body):
	validate_then_hit(body)



func validate_then_hit(target):
	var self_destroy = false

	### HIT AREA VALIDATION ### 
	if TargetGroup.is_in_platform_group(target):
		self_destroy = true
	elif TargetGroup.is_target_in_groups(target, target_groups):
		TargetGroup.damage_target(target, damage)

		# if current bullet can pierce through target, do not destroy it
		self_destroy = !piercing

	### ANIMATION ###
	if self_destroy:
		play_destroy_animation()


func play_destroy_animation():
	# Stop the projectile from moving
	set_process(false)
	set_physics_process(false)

	if hit_anim:
		if hit_anim.has_method("play"):
			hit_anim.play("destroy")
		elif hit_anim.has_method("start"):
			hit_anim.start()
	else:
		destroy()


func _on_life_timer_timeout():
	play_destroy_animation()


func _on_hit_animation_finished():
	destroy()


func _on_hit_animation_tween_completed(object, key):
	destroy()

func _on_screen_exited():
	destroy()


func destroy():
	queue_free()