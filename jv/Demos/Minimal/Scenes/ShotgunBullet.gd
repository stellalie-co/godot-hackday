extends "res://jv/Engine/Weapon/Projectile.gd"

const radius = 10
var position_inside_cone
var normal
var destination


func _physics_process(delta):
	var linear_vel = normal * delta * speed
	set_position(get_position() + linear_vel)


func prepare(start_position, flip_horizontal, weapon_rotation, direction_guideline, index, total_projectiles):
	# call super method
	.prepare(start_position, flip_horizontal, weapon_rotation, direction_guideline, index, total_projectiles)

	# calculate the next arc position for the projectile to move along
	var angle_step = PI / 2 / total_projectiles
	# divide the range equally based on the total projectiles
	var angle = ( index - total_projectiles / 2 ) * angle_step  + deg2rad(weapon_rotation)
	var direction = Vector2(cos(angle), sin(angle))
	
	# this is the global position that the projectile will move along
	# starting from the start_position
	destination = start_position + direction * radius
	
	# normalize it to get the proper vector path
	normal = ((destination - get_position())).normalized()

	if direction_guideline.x != 0:
		normal.x *= direction_guideline.x


