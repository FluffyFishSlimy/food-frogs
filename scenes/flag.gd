extends Node2D
@onready var marker_2d: Marker2D = $Marker2D

func _ready() -> void:
	data.flag_pos = marker_2d.global_position
