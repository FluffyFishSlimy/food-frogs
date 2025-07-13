extends Node2D
@onready var navigation_region_2d: NavigationRegion2D = $frogs/NavigationRegion2D
@onready var drag_item_layer: CanvasLayer = $drag_item_layer

@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var drag_item = preload("res://scenes/drag_item.tscn")

func _ready() -> void:
	data.drag_item_start.connect(spawn_dragable)
	data.drag_stopped.connect(drag_stopped)
	data.spawn_bullet.connect(spawn_bullet)
	
func spawn_bullet(pos, trans, fruit):
	var new_bullet = bullet.instantiate()
	new_bullet.position = pos
	new_bullet.transform = trans
	add_child(new_bullet)
	
func spawn_dragable(fruit):
	var drag = drag_item.instantiate()
	drag.fruit_icon = fruit.fruit_sprite
	drag_item_layer.add_child(drag)

func drag_stopped():
	for child in drag_item_layer.get_children():
		child.queue_free()

func _on_bake_timer_timeout() -> void:
	navigation_region_2d.bake_navigation_polygon()
