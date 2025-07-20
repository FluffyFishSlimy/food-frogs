extends Label

func _ready() -> void:
	var offset = 5
	position.x += randf_range(-offset, offset)
	position.y += randf_range(-offset, offset)
	
	scale = Vector2.ZERO
	
	pivot_offset.x = size.x/2
	pivot_offset.y = size.y/2
	
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, "scale", Vector2(1, 1), 0.3)
	t.chain().tween_property(self, "scale", Vector2(1, 1), 0.5)
	t.chain().tween_property(self, "scale", Vector2(0, 0), 0.2)
	await t.finished
	queue_free()
