extends Area2D

var speed:float = 600
@export var bullet_damge = 1
var bullet_peice:bool = false

func _process(delta: float) -> void:
	#speed = lerp(speed, 0.0, 0.01)
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	body.take_damage(bullet_damge)
	if bullet_peice == false:
		queue_free()

func _on_timeout_timeout() -> void:
	if self:
		queue_free()
