static func draw_point_around_arc(target, center, radius, count):
	# draw main circle
	target.draw_circle(center, radius, Color(1.0, 0.0, 0.0))

	var angle_step = PI / 2 / count
	# add point based on count
	for index in count:
		var angle = ( index - count / 2 ) * angle_step
		var direction = Vector2(cos(angle), sin(angle))
		var child_pos = center + direction * radius
		target.draw_circle(child_pos, 5, Color(1.0, 1.0, 0.0))