extends Node2D
@onready var fruit_icon_node: TextureRect = $Panel/fruit_icon
@onready var panel: Panel = $Panel

var fruit_icon:CompressedTexture2D

func _ready() -> void:
	fruit_icon_node.texture = fruit_icon
	position = get_global_mouse_position()

func _physics_process(_delta: float) -> void:
	position = lerp(position, get_global_mouse_position(), 0.3)

func _on_button_rotate_timeout() -> void:
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(panel, "rotation", 0.05, 0.2)
	t.chain().tween_property(panel, "rotation", -0.05, 0.2)
