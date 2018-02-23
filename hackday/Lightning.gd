extends "res://jv/Engine/Weapon/Projectile.gd"

var normal
var top_pos
var destination
var step = 100


func _physics_process(delta):
	var linear_vel = Vector2(0, delta * speed)
	set_position(get_position() + linear_vel)


func prepare(start_position, flip_horizontal, weapon_rotation, direction_guideline, index, total_projectiles):
	start_position = Vector2(start_position.x - index * step, start_position.y - 500)
	# call super method
	.prepare(start_position, flip_horizontal, weapon_rotation, direction_guideline, index, total_projectiles)

