extends "res://jv/Engine/AI/Enemy/EnemyAbility.gd"

enum Skill_Activation { RANDOM, IN_ORDER, PRIORITY }

export(Skill_Activation) var skill_activation = IN_ORDER
export(float) var delay_between_skills = 1

var current_skill
var skills
var timer


func _ready():
	skills = get_children()

	for skill in skills:
		skill.set_target_groups(get_target_groups())
		
	if delay_between_skills > 0:
		timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(delay_between_skills)
		timer.connect("timeout", self, "_on_delay_timer_timeout")
		

func _physics_process(delta):
	if !timer or timer.is_stopped():
		current_skill = get_skill_to_activate()
		if current_skill:
			current_skill.activate()
			restart_timer()



func get_skill_to_activate():
	### GET ACTIVATE SKILL ###
	match skill_activation:
		IN_ORDER:
			var _skills = []
			for skill in skills:
				if skill.can_activate():
					_skills.append(skill)
			
			var size = _skills.size()
			if size == 1:
				return _skills[0]
			elif size > 1:
				for skill in _skills:
					if skill != current_skill:
						return skill
		RANDOM:
			var _skills = []
			for skill in skills:
				if skill.can_activate():
					_skills.append(skill)
					
			var size = _skills.size()
			if size:
				return _skills[rand_range(0, size)]
		PRIORITY:
			var _skill
			for skill in skills:
				if skill.can_activate():
					if !_skill:
						_skill = skill
					elif skill.get_priority() < _skill.get_priority():
						_skill = skill
			return _skill
	return null
	
func restart_timer():
	if timer:
		timer.start()
	
func _on_delay_timer_timeout():
	timer.stop()