extends PathFollow2D
@onready var fruit_icon: TextureRect = $button/fruit_icon
@onready var button: Button = $button

var fruit_type:Fruit
var pressed = false

# Speed in pixels per second
@export var speed: float = 20
# Whether the path should loop
@export var loop_path: bool = true

func _ready():
	progress = data.fruit_mixer_progress
	data.fruit_mixer_progress += 100
	set_loop(loop_path)
	add_button_animations()
	fruit_icon.texture = fruit_type.fruit_sprite
	data.drag_item_start.connect(drag_start)
	data.drag_stopped.connect(drag_stopped)
	data.mix.connect(lock_in)
	
func lock_in():
	pressed = true

	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, "speed", 200, 1)
	await get_tree().create_timer(1).timeout
	var t2 = create_tween().set_trans(Tween.TRANS_CIRC)
	t2.tween_property(self, "speed", 0.1, 1)

func delete_fruit():
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(0, 0), 0.5)
	await t.finished
	queue_free()

func drag_start(_fruit):
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 1

func drag_stopped():
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	modulate.a = 1

func _process(delta):
	progress += speed * delta

func add_button_animations():
	var buttons = [
		button
	]
	for button in buttons:
		button.pivot_offset = Vector2(button.size.x/2, button.size.y/2)
		button.mouse_entered.connect(button_scale_up.bind(button))
		button.mouse_exited.connect(button_scale_down.bind(button))
		button.button_down.connect(button_down_pressed.bind(button))
		button.button_up.connect(button_released.bind(button))
		#button.pressed.connect(button_click_sound.bind(button))

func button_scale_up(button):
	if data.mixing == false:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
		SoundManager.play_sound("button_hover", randf_range(0.9, 1.1), 0)

func button_scale_down(button):
	if data.mixing == false:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
		t.tween_property(button, "rotation", 0, 0.2)

func button_click_sound(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(0.85, 0.85), 0.1)
	t.chain().tween_property(button, "scale", Vector2(1, 1), 0.1)
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)

func button_down_pressed(button):
	if data.mixing == false:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(button, "scale", Vector2(0.85, 0.85), 0.1)
		SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)
	
func button_released(button):
	if data.mixing == false:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(button, "scale", Vector2(1, 1), 0.1)
	if pressed == false:
		pressed = true
		data.fruit_mixer_progress -= 100
		# remove fruit from list
		data.fruits_in_mixer.remove_at(data.fruits_in_mixer.find(fruit_type))
		data.mixer_updated.emit()
		
		data.add_fruit_to_inv.emit(fruit_type)
		
		var t2 = create_tween().set_trans(Tween.TRANS_CIRC)
		t2.tween_property(self, 'scale', Vector2(0, 0), 0.2)
		await t2.finished
		queue_free()
