extends Area2D
@onready var animation_player: AnimationPlayer = $enemy_detect/AnimationPlayer
@onready var enemy_detect: Area2D = $enemy_detect
@onready var puddle_timer: Timer = $puddle_timer

var speed:float = 600
@export var bullet_damge = 1
var bullet_peice:bool = false
var bounces = 0
var homing = false
var exploads = false
var puddle = false
var puddle_dmg = 1
var puddle_color = Color("#3af912")

var enemy_body
var homing_speed = 600

func _ready() -> void:
	data.bullets_shot += 1
	SoundManager.play_sound("shoot", randf_range(0.8, 1.2), -15)
	if homing:
		animation_player.play("scale")
	else:
		enemy_detect.queue_free()
	
	if puddle:
		puddle_timer.start(0.1)

func _process(delta: float) -> void:
	#speed = lerp(speed, 0.0, 0.01)
	if homing and enemy_body != null:
		global_position = global_position.move_toward(enemy_body.global_position, homing_speed * delta)
	else:
		position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	body.take_damage(bullet_damge)
	SoundManager.play_sound('tick', randf_range(0.8, 1.2), -10)
	data.dmg_num.emit(body.global_position, bullet_damge)
	if exploads:
		data.exploasion.emit(global_position)
	if bullet_peice == false:
		if bounces <= 0:
			queue_free()
		else:
			SoundManager.play_sound('boing', randf_range(0.8, 1.2), -10)
			rotation_degrees += 180 + randf_range(-50, 50)
			bounces -= 1

func _on_timeout_timeout() -> void:
	if self:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if bounces <= 0:
		if exploads:
			data.exploasion.emit(global_position)
		queue_free()
	else:
		SoundManager.play_sound('boing', randf_range(0.8, 1.2), -10)
		rotation_degrees += 180
		bounces -= 1

func _on_enemy_detect_body_entered(body: Node2D) -> void:
	if enemy_body == null:
		enemy_body = body

func _on_puddle_timer_timeout() -> void:
	data.spawn_puddle.emit(global_position, puddle_dmg, puddle_color)
