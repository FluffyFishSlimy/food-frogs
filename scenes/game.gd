extends Node2D
@onready var navigation_region_2d: NavigationRegion2D = $frogs/NavigationRegion2D

func _on_bake_timer_timeout() -> void:
	navigation_region_2d.bake_navigation_polygon()
