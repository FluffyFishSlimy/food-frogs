extends CanvasLayer
@onready var transition: ColorRect = $transition
@onready var percentage: Label = $health/percentage
@onready var health_bar: ProgressBar = $health
@onready var settings_button: Button = $settings

var wiggle_button_object

func _ready() -> void:
	transition.show()
	add_button_animations()

func _physics_process(_delta: float) -> void:
	health_bar.value = lerp(health_bar.value, data.health, 0.2)
	percentage.text = "Health: " + str(clamp(int(round(data.health)), 0, 100)) + "%"

func add_button_animations():
	var buttons = [
		settings_button
	]
	for button in buttons:
		button.pivot_offset = Vector2(button.size.x/2, button.size.y/2)
		button.mouse_entered.connect(button_scale_up.bind(button))
		button.mouse_exited.connect(button_scale_down.bind(button))
		button.button_down.connect(button_down_pressed.bind(button))
		button.button_up.connect(button_released.bind(button))

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
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)
	
func button_released(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(1, 1), 0.1)

func _on_button_rotate_timeout() -> void:
	if wiggle_button_object != null:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(wiggle_button_object, "rotation", 0.05, 0.2)
		t.chain().tween_property(wiggle_button_object, "rotation", -0.05, 0.2)
