extends Button
@onready var fruit_icon: TextureRect = $fruit_icon
@onready var count: Label = $count

var wiggle_button_object = null
var fruit_type = data.fruits[randi_range(0, data.fruits.size()-1)]

func _ready() -> void:
	add_button_animations()
	fruit_icon.texture = fruit_type.fruit_sprite
	count.text = "x" + str(randi_range(1, 10))

func add_button_animations():
	var buttons = [
		self
	]
	for button in buttons:
		button.pivot_offset = Vector2(button.size.x/2, button.size.y/2)
		button.mouse_entered.connect(button_scale_up.bind(button))
		button.mouse_exited.connect(button_scale_down.bind(button))
		button.button_down.connect(button_down_pressed.bind(button))
		button.button_up.connect(button_released.bind(button))
		#button.pressed.connect(button_click_sound.bind(button))

func button_scale_up(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
	wiggle_button_object = button
	SoundManager.play_sound("button_hover", randf_range(0.9, 1.1), 0)

func button_scale_down(button):
	wiggle_button_object = null
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
	t.tween_property(button, "rotation", 0, 0.2)

func button_click_sound(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(0.85, 0.85), 0.1)
	t.chain().tween_property(button, "scale", Vector2(1, 1), 0.1)
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)

func button_down_pressed(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(0.85, 0.85), 0.1)
	modulate.a = 0.5
	data.drag_item_start.emit(fruit_type)
	data.holding_fruit = true
	data.item_seletecd = fruit_type
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)
	
func button_released(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	modulate.a = 1
	data.drag_stopped.emit()
	data.holding_fruit = false
	t.tween_property(button, "scale", Vector2(1, 1), 0.1)

func _on_button_rotate_timeout() -> void:
	if wiggle_button_object != null:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(wiggle_button_object, "rotation", 0.05, 0.2)
		t.chain().tween_property(wiggle_button_object, "rotation", -0.05, 0.2)
