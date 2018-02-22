# jv-godot/Common/TargetGroup

static func is_target_in_groups(target, groups):
	for group in groups:
		if target and target.is_in_group(group):
			return true
	return false
	
static func is_in_platform_group(target):
	return target.is_in_group("platform")
	

static func is_in_destructible_group(target):
	return target.is_in_group("destructible")
	

static func damage_target(target, damage, options={}):
	if target and target.has_meta("receive_damage"):
		target.get_meta("receive_damage").call_func(damage, options)
		return true
	return false