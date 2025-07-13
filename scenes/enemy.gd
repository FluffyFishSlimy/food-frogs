extends CharacterBody2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $flag_detect/AnimationPlayer

var speed = 25
var damage = 1
var health = 3
var coin_value = 1

func _ready() -> void:
	await get_tree().create_timer(randf_range(0.1, 1)).timeout
	animation_player.play("attack")

func take_damage(dmg):
	health -= dmg
	# die
	if health <= 0:
		data.spawn_coin.emit(global_position, coin_value)
		queue_free()

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

func _on_area_2d_area_entered(_area: Area2D) -> void:
	data.health -= damage
