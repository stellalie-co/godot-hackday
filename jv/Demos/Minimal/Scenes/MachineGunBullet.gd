extends "res://jv/Engine/Weapon/Projectile.gd"


func _ready():
	var zeroOpacityModulate = self.get_modulate()
	zeroOpacityModulate.a = 0
	hit_anim.interpolate_property(self, "scale", self.get_scale(), 
								Vector2(2.0, 2.0), 0.3, 
								Tween.TRANS_QUAD, Tween.EASE_OUT)
	hit_anim.interpolate_property(self, "modulate", self.get_modulate(), 
								zeroOpacityModulate, 0.3, 
								Tween.TRANS_QUAD, Tween.EASE_OUT)


func _physics_process(delta):
	var linear_vel = direction_guideline * speed
	linear_vel *= delta 

	set_position(get_position() + linear_vel)
