extends "res://jv/Engine/Common/BaseController.gd"

export(String, "left", "right") var agent_initial_facing_direction = "left"


func get_agent_initial_facing_direction():
	return agent_initial_facing_direction