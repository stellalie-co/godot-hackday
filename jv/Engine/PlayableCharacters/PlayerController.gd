# jv-godot/PlayableCharacters/PlayerController
extends "res://jv/Engine/Common/BaseController.gd"

# EXPORT ==============================
# player input name like player1 or player2
# change this when you want to support multiple players
export var action_player_input_name = ""
export var action_ui_right = "ui_right"
export var action_ui_left = "ui_left"
export var action_ui_down = "ui_down"
export var action_ui_up = "ui_up"
export var action_ui_jump = "ui_jump"
export var action_ui_shoot = "ui_shoot"


# VARIABLE =============================
var agent_animation_prefix
var agent_animation_modifer

func get_action(action_name):
	if action_player_input_name:
		return action_player_input_name + "_" + self[action_name]
	return self["action_" + action_name]
