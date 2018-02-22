# jv-godot/Weapon/ProjectileWeapon
extends Node2D

enum Mode { MANUAL, SEMI_AUTO, AUTO }

# EXPORT ==============================
# REQUIRED - the projectile scene class that will be initialized each time user shoots
export(PackedScene) var projectile_type

# REQUIRED
export(bool) var active = false

# OPTIONAL - name of current weapon
export(String) var weapon_animation_identifier setget ,get_weapon_animation_identifier

# OPTIONAL - the start position of the projectile when it is first created
export(NodePath) var projectile_start_position

export(NodePath) var audio_player

# OPTIONAL - how long before user can shoot again. Set to 0 to have projectiles
# continuously created
export(float) var waiting_time = 0.5

# OPTIONAL - how many projectiles are created at a time
export(int) var spawn_count = 1

# OPTIONAL - override damage of bullet
export(int) var override_bullet_damage = 0

# OPTIONAL - override speed of bullet
export(int) var override_bullet_speed = 0


# OPTIONAL - shooting mode
export(Mode) var mode = Mode.SEMI_AUTO

# CONSTANT ============================



# CACHING =============================
onready var controller = get_parent().get_controller()
onready var action_ui_shoot = controller.get_action("ui_shoot")
onready var action_ui_right = controller.get_action("ui_right")
onready var action_ui_left = controller.get_action("ui_left")
onready var action_ui_down = controller.get_action("ui_down")
onready var action_ui_up = controller.get_action("ui_up")
onready var projectile_parent = get_tree().get_root()

# VARIABLES ===========================
var target_groups = []
# This variable is being used in Mode.MANUAL only
var can_manually_spawn_projectiles = true
var timer
var start_position
var shoot_animation
var current_animation_state
var audio



func _ready():
	
	if projectile_start_position:
		start_position = get_node(projectile_start_position)
	else:
		start_position = Position2D.new()
		add_child(start_position)
		
	if audio_player:
		audio = get_node(audio_player)
	
	# Reset spawn_count
	if spawn_count <= 0:
		spawn_count = 1
	
	# Setup timer to prevent too many projectiles are created when user presses the shoot button 
	if waiting_time > 0:
		timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(waiting_time)
		timer.connect("timeout", self, "_on_timer_timeout")
		
	controller.listen_for_status_updated(self, "_on_status_updated")


func _input(event):
	if !active:
		return
	
	if event.is_action_released(action_ui_shoot):
		if mode == Mode.MANUAL or mode == Mode.SEMI_AUTO:
			can_manually_spawn_projectiles = true
			controller.play_agent_animation(current_animation_state)
			


func _physics_process(delta):	
	### SHOTTING MODE ###
	# Use timer to prevent too many projectiles are spawned at one time
	if !timer or timer.is_stopped():
		match mode:
			AUTO:
				spawn_projectiles()
			SEMI_AUTO:
				if Input.is_action_pressed(action_ui_shoot):
					spawn_projectiles()
			MANUAL:
				if can_manually_spawn_projectiles and Input.is_action_pressed(action_ui_shoot):
					spawn_projectiles()
					can_manually_spawn_projectiles = false


func set_target_groups(groups):
	target_groups = groups



func spawn_projectiles():
	var current_rotation = get_rotation_degrees()
	var projectile_start_position = start_position.get_global_position()
	var flip_horizontal = controller.get_agent_data("flip_horizontal")
	var direction_guideline = get_direction_guideline(flip_horizontal)
	
	controller.play_agent_animation(shoot_animation)
	if audio:
		audio.play()

	for index in spawn_count:
		var projectile = projectile_type.instance()
		projectile_parent.add_child(projectile)
		if override_bullet_damage > 0:
			projectile.set_damage(override_bullet_damage)
		if override_bullet_speed > 0:
			projectile.set_speed(override_bullet_speed)
		projectile.prepare(projectile_start_position, flip_horizontal, current_rotation, direction_guideline, index, spawn_count)
		projectile.set_target_groups(target_groups)

	if timer:
		restart_timer()

	
	
func get_direction_guideline(flip_horizontal):
	# Right
	var direction_guideline = Vector2(1, 0)
	var current_rotation = get_rotation_degrees()

	# Left
	if current_rotation == 0 and flip_horizontal:
		direction_guideline = Vector2(-1, 0)
	# Up
	elif current_rotation == -90:
		direction_guideline = Vector2(0, -1)
	# Down
	elif current_rotation == 90:
		direction_guideline = Vector2(0, 1)
	# Up right
	elif current_rotation == -45 and !flip_horizontal:
		direction_guideline = Vector2(1, -1)
	# Down right
	elif current_rotation == 45 and !flip_horizontal:
		direction_guideline = Vector2(1, 1)
	# Up left
	elif current_rotation == -45 and flip_horizontal:
		direction_guideline = Vector2(-1, -1)
	# Down right
	elif current_rotation == 45 and flip_horizontal:
		direction_guideline = Vector2(-1, 1)
		
	return direction_guideline

func get_weapon_animation_identifier():
	return weapon_animation_identifier


func get_active():
	return active
	
func set_active(value):
	active = value
	set_process(value)
	set_physics_process(value)
	set_visible(value)


func restart_timer():
	timer.start()

func _on_timer_timeout():
	timer.stop()
	
func _on_status_updated(status, options):
	if status == "movement":
		current_animation_state = options.state
		shoot_animation = current_animation_state + "-shoot"
