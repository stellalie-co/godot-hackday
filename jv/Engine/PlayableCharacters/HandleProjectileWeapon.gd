# jv-godot/PlayableCharacters/HandleWeapon
extends "res://jv/Engine/PlayableCharacters/CharacterAbility.gd"

# ENUMS ===============================
enum Direction { LEFT_RIGHT, LEFT_RIGHT_UP, ALL }

# EXPORT ==============================
# OPTIONAL - what angle + direction the current projectile weapon can change
export(Direction) var direction = Direction.LEFT_RIGHT


# CONSTANT ============================



# CACHING =============================
onready var action_ui_shoot = get_controller().get_action("ui_shoot")
onready var action_ui_right = get_controller().get_action("ui_right")
onready var action_ui_left = get_controller().get_action("ui_left")
onready var action_ui_down = get_controller().get_action("ui_down")
onready var action_ui_up = get_controller().get_action("ui_up")


# VARIABLE ============================
var current_weapon
var previous_weapon_rotation
var weapon_rotation
var weapon_rotation_animation


func _ready():
	var _weapon

	for weapon in get_children():
		if weapon.get_active():
			_weapon = weapon
		# deactive all weapons
		weapon.set_active(false)
	
	if !_weapon and get_child_count() > 0:
		_weapon = get_child(0)

	set_active_weapon(_weapon)



func _input(event):
	# Reset weapon_rotation
	if event.is_action_released(action_ui_up) or event.is_action_released(action_ui_down):
		weapon_rotation = 0


func _physics_process(delta):
	handle_direction()


func set_active_weapon(weapon):
	current_weapon = weapon
	current_weapon.set_active(true)
	current_weapon.set_target_groups(target_groups)

	var weapon_animation_identifier = current_weapon.get_weapon_animation_identifier()
	if weapon_animation_identifier:
		controller.set_agent_animation_identifier(weapon_animation_identifier)



func handle_direction():
	weapon_rotation = 0

	### WEAPON ROTATION ###
	# Change rotation based on what kind of directional inputs combination are being used
	if direction == Direction.LEFT_RIGHT_UP or direction == Direction.ALL:
		if Input.is_action_pressed(action_ui_up):
			weapon_rotation = -90.0

	if direction == Direction.ALL:
		if Input.is_action_pressed(action_ui_up):
			if Input.is_action_pressed(action_ui_right) or Input.is_action_pressed(action_ui_left):
				weapon_rotation = -45.0

		if Input.is_action_pressed(action_ui_down):
			weapon_rotation = 90.0

			if Input.is_action_pressed(action_ui_right) or Input.is_action_pressed(action_ui_left):
				weapon_rotation = 45.0

	current_weapon.set_rotation_degrees(weapon_rotation)
	if weapon_rotation != previous_weapon_rotation:
		previous_weapon_rotation = weapon_rotation
		
		### PLAY ANIMATION ###
		# Each rotation will require combination of current action + rotation 
		if weapon_rotation == -90.0:
			weapon_rotation_animation = "90-up"
		elif weapon_rotation == 90.0:
			weapon_rotation_animation = "90-down"
		elif weapon_rotation == -45.0:
			weapon_rotation_animation = "45-up"
		elif weapon_rotation == 45.0:
			weapon_rotation_animation = "45-down"
		else:
			weapon_rotation_animation = null
		controller.set_agent_animation_modifier(weapon_rotation_animation)


	
