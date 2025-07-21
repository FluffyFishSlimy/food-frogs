extends Control
@onready var master_slider: HSlider = $Panel/VBoxContainer/HBoxContainer2/master_vol
@onready var music_slider: HSlider = $Panel/VBoxContainer/HBoxContainer/music_vol
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/HBoxContainer3/sfx_vol
@onready var master_label: Label = $Panel/VBoxContainer/HBoxContainer2/master_vol_text
@onready var music_label: Label = $Panel/VBoxContainer/HBoxContainer/music_vol_text
@onready var sfx_label: Label = $Panel/VBoxContainer/HBoxContainer3/sfx_vol_text
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var back: Button = $Panel/back

var master_index:int
var music_index:int
var sfx_index:int
var back_pressed = false
var is_open = false

var wiggle_button_object = null

func _ready() -> void:
	add_button_animations()
	
	master_index = AudioServer.get_bus_index('Master')
	master_slider.value_changed.connect(_on_value_master_changed)
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_index))
	
	music_index = AudioServer.get_bus_index('Music')
	music_slider.value_changed.connect(_on_value_music_changed)
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_index))
	
	sfx_index = AudioServer.get_bus_index('SFX')
	sfx_slider.value_changed.connect(_on_value_sfx_changed)
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))

func _on_value_master_changed(value:float):
	AudioServer.set_bus_volume_db(master_index, linear_to_db(value))
	master_label.text = 'Master  -  ' + str(int(master_slider.value*100)) + '%'

func _on_value_music_changed(value:float):
	AudioServer.set_bus_volume_db(music_index, linear_to_db(value))
	music_label.text = 'Music  -  ' + str(int(music_slider.value*100)) + '%'

func _on_value_sfx_changed(value:float):
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))
	sfx_label.text = 'SFX  -  ' + str(int(sfx_slider.value*100)) + '%'

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("settings"):
		if is_open:
			close()
		else:
			open()
			
func open():
	back_pressed = false
	is_open = true
	animation_player.play("open")
	data.settings_opened.emit()

func close():
	if back_pressed == false:
		is_open = false
		back_pressed = true
		data.settings_closed.emit()
		animation_player.play_backwards("open")

func _on_back_pressed() -> void:
	close()

func add_button_animations():
	var buttons = [
		back
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

func _on_button_rotate_timeout() -> void:
	if wiggle_button_object != null:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(wiggle_button_object, "rotation", 0.05, 0.2)
		t.chain().tween_property(wiggle_button_object, "rotation", -0.05, 0.2)
