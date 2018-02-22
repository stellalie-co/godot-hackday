# jv-godot/Helper/RaycastsGenerator
extends Object


var rays = []
var t_instance
var flip_horizontal = false


func set_target_instance(target_instance):
	t_instance = target_instance


func generate(number_of_raycasts, ray_x, ray_y, ray_gap):
	for i in number_of_raycasts:
		var ray = RayCast2D.new()
		var y = ray_y + (i - number_of_raycasts / 2) * ray_gap
		ray.set_cast_to(Vector2(ray_x, y))
		ray.set_enabled(true)
		t_instance.call_deferred("add_child", ray)
		rays.append(ray)

	return rays


func flip_rays():
	for ray in rays:
		ray.scale.x = -ray.scale.x
	flip_horizontal = !flip_horizontal
	return flip_horizontal


func draw_debug_lines(instance, number_of_raycasts, ray_x, ray_y, ray_gap):
	for i in number_of_raycasts:
		var y = ray_y + (i - number_of_raycasts / 2) * ray_gap
		instance.draw_line(Vector2(0, 0), Vector2(ray_x, y), Color(1.0, 0.0, 0.0))
