extends CharacterBody2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

var speed = 50

func _physics_process(_delta: float) -> void:
	
	look_at(data.flag_pos)
	
	# With pathfinding
	var next_path_pos := navigation_agent_2d.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	velocity = dir * speed
	
	move_and_slide()

func makepath():
	navigation_agent_2d.target_position = data.flag_pos

func _on_pathfind_timeout() -> void:
	makepath()
