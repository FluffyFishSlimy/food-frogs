extends Control
@onready var eyeball_left: Panel = %eyeball_left
@onready var eyeball_right: Panel = %eyeball_right

func _physics_process(delta: float) -> void:
	if data.holding_fruit:
		
		var look_scale = 3
		var offset = Vector2(4, 7)
		
		if position.distance_to(get_global_mouse_position()) < 200:
			
			var target_pos_left = eyeball_left.global_position.direction_to(get_global_mouse_position())*look_scale
			eyeball_left.position = lerp(eyeball_left.position, Vector2(target_pos_left.x+offset.x, target_pos_left.y+offset.y), 0.5)
			
			var target_pos_right = eyeball_right.global_position.direction_to(get_global_mouse_position())*look_scale
			eyeball_right.position = lerp(eyeball_right.position, Vector2(target_pos_right.x+offset.x, target_pos_right.y+offset.y), 0.5)
		else:
			var target_pos_left = Vector2.ZERO
			eyeball_left.position = lerp(eyeball_left.position, Vector2(target_pos_left.x+offset.x, target_pos_left.y+offset.y), 0.5)
			
			var target_pos_right = Vector2.ZERO
			eyeball_right.position = lerp(eyeball_right.position, Vector2(target_pos_right.x+offset.x, target_pos_right.y+offset.y), 0.5)
