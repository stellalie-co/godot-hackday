extends "res://jv/Engine/AI/Enemy/EnemyAbility.gd"

export(int) var damage_target_on_contact = 10
export(int) var bounce_up_height = 400
export(int) var bounce_up_speed = 50

# CONSTANT ============================
const TargetGroup = preload("res://jv/Engine/Common/TargetGroup.gd")


var max_height
var bounce_vel
var hit_target

func _ready():
	var agent = get_controller().get_agent()
	agent.connect("area_entered", self, "_on_area_entered")
	agent.connect("body_entered", self, "_on_body_entered")


func _physics_process(delta):
	if hit_target:
		var target = hit_target.get_ref()
		if target and target.position.y > max_height:
			target.position.y -= bounce_up_speed
		else:
			max_height = 0
			hit_target = null



func _on_area_entered(area):
	validate_then_hit(area)
	
func _on_body_entered(body):
	validate_then_hit(body)


func validate_then_hit(target):
	var self_destroy = false

	### HIT AREA VALIDATION ### 
	if TargetGroup.is_target_in_groups(target, target_groups):
		max_height = target.position.y - bounce_up_height
		hit_target = weakref(target)
		TargetGroup.damage_target(target, damage_target_on_contact)
