extends Node2D
@onready var marker_2d: Marker2D = $Marker2D

func _ready() -> void:
	data.flag_pos = marker_2d.global_position
	
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#data.health -= area.get_parent().damage
	#print('Took damage from: ' + str(area))
