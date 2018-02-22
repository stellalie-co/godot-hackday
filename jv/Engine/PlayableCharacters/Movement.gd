# jv-godot/PlayableCharacters/Movement
extends "res://jv/Engine/PlayableCharacters/CharacterAbility.gd"

# EXPORT ==============================
export var gravity = 900
export var run_speed = 250 # pixels/sec
export var slope_slide_stop = 25.0
export var jump_speed = 480
export var min_jump = 300
export var extra_jump = 1
export(NodePath) var movement_sound_player
export(bool) var prevent_input_on_hit = true


# CONSTANT ============================
const FLOOR_NORMAL = Vector2(0, -1)
const SIDING_CHANGE_SPEED = 10
const MIN_ON_AIR_TIME = 0.05


# CACHING =============================
onready var p_torso = get_controller().get_agent_torso()
onready var action_ui_right = get_controller().get_action("ui_right")
onready var action_ui_left = get_controller().get_action("ui_left")
onready var action_ui_down = get_controller().get_action("ui_down")
onready var action_ui_jump = get_controller().get_action("ui_jump")



# VARIABLES ===========================
var linear_vel = Vector2()
var on_air_time = 0
var on_floor = false
var max_jump = false
var current_jump_count = 0
var has_jumped = false
var gravity_vel = Vector2(0, gravity)
var current_animation
var prevent_user_input = false


func _ready():
	if movement_sound_player:
		sound_manager = get_agent().get_node(movement_sound_player)
	get_controller().listen_for_status_updated(self, "_on_status_updated")


func _input(event):
	if prevent_user_input:
		return false
	
	if !on_floor:
		if event.is_action_released(action_ui_jump) and !has_jumped:
			has_jumped = true
			linear_vel.y = clamp(linear_vel.y, -min_jump, linear_vel.y)

		# Handle extra jump 
		if extra_jump > 0 and has_jumped and event.is_action_pressed(action_ui_jump) and current_jump_count < extra_jump:
			current_jump_count += 1
			linear_vel.y -= jump_speed * 0.8
			play_sound("double_jump")



func _physics_process(delta):
	if prevent_user_input:
		return false
	
	var player = get_agent()
	
	#increment counters
	on_air_time += delta
	
	
	### MOVEMENT ###
	
	# Apply Gravity
	linear_vel += delta * gravity_vel
	
	# Move
	linear_vel = player.move_and_slide(linear_vel, FLOOR_NORMAL, slope_slide_stop)
	
	
	# Detect floor
	if player.is_on_floor():
		on_air_time = 0
		
	on_floor = on_air_time < MIN_ON_AIR_TIME


	### PLAYER CONTROL ###
	
	# Horizontal movement
	var target_speed = 0
	if Input.is_action_pressed(action_ui_left):
		target_speed += -1
	elif Input.is_action_pressed(action_ui_right):
		target_speed += 1

	target_speed *= run_speed
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)
	
	# Jumping
	if on_floor:
		# reset jump variables
		has_jumped = false
		current_jump_count = 0

		# handle jump
		if Input.is_action_pressed(action_ui_jump):
			linear_vel.y = -jump_speed
			play_sound("jump")



	### ANIMATION ###
	var new_animation = "idle"
	
	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			p_torso.scale.x = -1
			new_animation = "run"
			controller.set_agent_data("flip_horizontal", true)

		if linear_vel.x > SIDING_CHANGE_SPEED:
			p_torso.scale.x = 1
			new_animation = "run"
			controller.set_agent_data("flip_horizontal", false)
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed(action_ui_left) and not Input.is_action_pressed(action_ui_right):
			p_torso.scale.x = -1
			controller.set_agent_data("flip_horizontal", true)
		if Input.is_action_pressed(action_ui_right) and not Input.is_action_pressed(action_ui_left):
			p_torso.scale.x = 1
			controller.set_agent_data("flip_horizontal", false)

		if linear_vel.y < 0:
			new_animation = "extra_jump" if current_jump_count > 0 else "jump"				
		else:
			new_animation = "fall"

	if new_animation != current_animation:
		current_animation = new_animation
		controller.play_agent_animation(new_animation)
		

func _on_status_updated(status, options):
	if prevent_input_on_hit:
		if status == "hit":
			prevent_user_input = true
			get_controller().get_agent_shape().set_disabled(true)
		elif status == "recover_after_hit":
			prevent_user_input = false
			get_controller().get_agent_shape().set_disabled(false)
