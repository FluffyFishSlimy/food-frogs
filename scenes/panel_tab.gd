extends Button
@onready var icon_texture: TextureRect = $icon
@onready var tab_name_label: Label = $tab_name

@export var tab_icon:CompressedTexture2D
@export var tab_name:String = 'TabName'

func _ready() -> void:
	icon_texture.texture = tab_icon
	tab_name_label.text = tab_name
	tab_name_label.scale = Vector2(0, 0)
	self_modulate = Color('#ffffff')
	data.tab_change.connect(tab_changed)
	data.tab_change.emit()

func tab_changed():
	self_modulate = Color('#ffffff')
	if data.tab_selected == tab_name:
		self_modulate = Color('#d0f0c2')

func _on_mouse_entered() -> void:
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, 'position', Vector2(10, position.y), 0.2)
	t.tween_property(tab_name_label, 'scale', Vector2(1, 1), 0.1)
	var t2 = create_tween().set_trans(Tween.TRANS_CIRC)
	t2.tween_property(icon_texture, 'scale', Vector2(1.3, 1.3), 0.2)
	SoundManager.play_sound("button_hover", randf_range(0.9, 1.1), 0)

func _on_mouse_exited() -> void:
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, 'position', Vector2(0, position.y), 0.2)
	t.tween_property(tab_name_label, 'scale', Vector2(0, 0), 0.1)
	var t2 = create_tween().set_trans(Tween.TRANS_CIRC)
	t2.tween_property(icon_texture, 'scale', Vector2(1.1, 1.1), 0.2)

func _on_pressed() -> void:
	self_modulate = Color('#d0f0c2')
	data.tab_selected = tab_name
	data.tab_change.emit()
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)
