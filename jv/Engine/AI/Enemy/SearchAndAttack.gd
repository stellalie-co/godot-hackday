extends "res://jv/Engine/AI/Enemy/EnemyAbility.gd"


export(int) var ray_x = -500
export(int) var ray_y = 0
export(int) var number_of_raycasts = 1
export(int) var ray_gap = 10


# CONSTANT ============================
const TargetGroup = preload("res://jv/Engine/Common/TargetGroup.gd")
const RaycastsGenerator = preload("res://jv/Engine/Helper/RaycastsGenerator.gd")


var raycast_generator
var rays
var target_to_attack

func _ready():
	raycast_generator = RaycastsGenerator.new()
	raycast_generator.set_target_instance(get_agent())
	rays = raycast_generator.generate(number_of_raycasts, ray_x, ray_y, ray_gap)


func _physics_process(delta):
	if search_target():
		start_attacking()


func search_target():
	for ray in rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if TargetGroup.is_target_in_groups(collider, get_target_groups()):
				target_to_attack = collider
				return true

	target_to_attack = null
	return false



func start_attacking():
	pass
	
	
# DEBUG ===================================
func _draw():
	if get_debug():
		raycast_generator.draw_debug_lines(self, number_of_raycasts, ray_x, ray_y, ray_gap)