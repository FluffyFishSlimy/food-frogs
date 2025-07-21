extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var speed:float = 600
@export var bullet_damge = 1
var bullet_peice:bool = false
var bounces = 0
var homing = false
var exploads = false
var puddle = false
var puddle_dmg = 1
var puddle_color = Color("#3af912")
var homing_speed = 600

func _ready() -> void:
	data.bullets_shot += 1
	SoundManager.play_sound("laser", randf_range(0.8, 1.2), -18)
	modulate.a = 0.9
	
func _on_body_entered(body: Node2D) -> void:
	body.take_damage(bullet_damge)
	SoundManager.play_sound('tick', randf_range(0.8, 1.2), -10)
	data.dmg_num.emit(body.global_position, bullet_damge)

func _on_timeout_timeout() -> void:
	if self:
		animation_player.speed_scale = 1.5
		animation_player.play_backwards("open")
		await animation_player.animation_finished
		queue_free()
