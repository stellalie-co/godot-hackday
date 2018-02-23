extends "res://jv/Engine/Weapon/Projectile.gd"



func _physics_process(delta):
	var linear_vel = direction_guideline * speed
	linear_vel *= delta 

	set_position(get_position() + linear_vel)
