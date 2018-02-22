extends "res://jv/Engine/AI/Enemy/EnemySkill.gd"

# EXPORT ==============================
# REQUIRED - the projectile scene class that will be initialized each time user shoots
export(PackedScene) var projectile_type

# OPTIONAL - name of current weapon
export(String) var projectile_animation_identifier setget ,get_projectile_animation_identifier

# OPTIONAL - the start position of the projectile when it is first created
export(NodePath) var projectile_start_position

# OPTIONAL - override damage of bullet
export(int) var override_bullet_damage = 0

# OPTIONAL - how many projectiles are created at a time
export(int) var spawn_count = 1

# OPTIONAL - defines the length of the ray which will be used to detect target
export(int) var ray_x = 300
export(int) var ray_y = 0
export(int) var number_of_raycasts = 1
export(int) var ray_gap = 10



# CACHING ==============================
onready var projectile_parent = get_tree().get_root()



# CONSTANT ============================
const TargetGroup = preload("res://jv/Engine/Common/TargetGroup.gd")
const RaycastsGenerator = preload("res://jv/Engine/Helper/RaycastsGenerator.gd")


var start_position
var raycast_generator
var rays
var target_found


func _ready():
	if projectile_start_position:
		start_position = get_node(projectile_start_position)
	else:
		start_position = Position2D.new()
		add_child(start_position)
		
	raycast_generator = RaycastsGenerator.new()
	raycast_generator.set_target_instance(get_agent())
	rays = raycast_generator.generate(number_of_raycasts, get_ray_x(), ray_y, ray_gap)
	get_controller().listen_for_status_updated(self, "_on_status_changed")
	


func _physics_process(delta):
	target_found = search_target()


# override
func can_activate():
	return target_found and .can_activate()


func get_projectile_animation_identifier():
	return projectile_animation_identifier


# override
func perform_skill():
	var controller = get_controller()
	var current_rotation = get_rotation_degrees()
	var projectile_start_position = start_position.get_global_position()
	var flip_horizontal = controller.get_agent_data("flip_horizontal")
	var direction_guideline = get_direction_guideline()

	for index in spawn_count:
		var projectile = projectile_type.instance()
		projectile_parent.add_child(projectile)
		if override_bullet_damage > 0:
			projectile.set_damage(override_bullet_damage)
		projectile.prepare(projectile_start_position, flip_horizontal, current_rotation, direction_guideline, index, spawn_count)
		projectile.set_target_groups(target_groups)


func search_target():
	for ray in rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if TargetGroup.is_target_in_groups(collider, get_target_groups()):
				return true
	return false


func get_direction_guideline():
	var direction_guideline = Vector2(-1, 0)
	var controller = get_controller()
	var moving_direction = controller.get_agent_data("moving_direction")

	if !moving_direction:
		moving_direction = controller.get_agent_initial_facing_direction()

	if moving_direction == "right":
		direction_guideline = Vector2(1, 0)

	return direction_guideline


func _on_status_changed(status, options):
	if status == "flip_horizontal":
		raycast_generator.flip_rays()


func get_ray_x():
	var facing_direction = get_controller().get_agent_initial_facing_direction()
	
	if facing_direction == "right":
		return ray_x
	return -ray_x


# DEBUG ===================================
func _draw():
	if get_debug():
		raycast_generator.draw_debug_lines(self, number_of_raycasts, get_ray_x(), ray_y, ray_gap)