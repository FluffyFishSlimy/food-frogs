extends Control
@onready var play: Button = $play
@onready var settings: Button = $settings
@onready var quit: Button = $quit
@onready var title: Label = $title
@onready var transition_animation: AnimationPlayer = $transition/transition_animation
@onready var credits: Button = %credits

var wiggle_button_object = null
var start_pressed = false

func _ready() -> void:
	add_button_animations()
	title.pivot_offset = Vector2(title.size.x/2, title.size.y/2)

func add_button_animations():
	var buttons = [
		play,
		settings,
		quit,
		credits
	]
	for button in buttons:
		button.pivot_offset = Vector2(button.size.x/2, button.size.y/2)
		button.mouse_entered.connect(button_scale_up.bind(button))
		button.mouse_exited.connect(button_scale_down.bind(button))
		button.pressed.connect(button_click_sound.bind(button))

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

func _on_quit_pressed() -> void:
	if start_pressed == false:
		await get_tree().create_timer(0.2).timeout
		get_tree().quit()


func _on_button_rotate_timeout() -> void:
	if wiggle_button_object != null:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(wiggle_button_object, "rotation", 0.05, 0.2)
		t.chain().tween_property(wiggle_button_object, "rotation", -0.05, 0.2)

func _on_play_pressed() -> void:
	if start_pressed == false:
		start_pressed = true
		transition_animation.play("close")
		await transition_animation.animation_finished
		get_tree().change_scene_to_file("res://scenes/game.tscn")
