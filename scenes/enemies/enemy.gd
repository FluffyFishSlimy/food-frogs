extends CharacterBody2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $flag_detect/AnimationPlayer

@export var speed = 25
@export var damage = 1
@export var health = 3
@export var coin_value = 1
var dead = false

func _ready() -> void:
	var scale_to = scale
	scale = Vector2.ZERO
	await get_tree().create_timer(randf_range(0.1, 1)).timeout
	animation_player.play("attack")
	
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, "scale", scale_to, 0.3)

func take_damage(dmg):
	health -= dmg
	# die
	if health <= 0 and dead == false:
		dead = true
		data.enemies_killed_this_round += 1
		data.enemy_count -= 1
		data.spawn_coin.emit(global_position, coin_value)
		data.enemies_killed += 1
		queue_free()

func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(data.flag_pos, speed * delta)
	look_at(data.flag_pos)
	
	# With pathfinding
	#var next_path_pos := navigation_agent_2d.get_next_path_position()
	#var dir := global_position.direction_to(next_path_pos)
	#velocity = dir * speed
	#
	move_and_slide()

func makepath():
	navigation_agent_2d.target_position = data.flag_pos

func _on_pathfind_timeout() -> void:
	makepath()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	data.health -= damage
