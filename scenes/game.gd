extends Node2D
@onready var navigation_region_2d: NavigationRegion2D = $frogs/NavigationRegion2D
@onready var drag_item_layer: CanvasLayer = $drag_item_layer

@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var drag_item = preload("res://scenes/drag_item.tscn")
@onready var coin = preload("res://scenes/coin.tscn")

func _ready() -> void:
	data.drag_item_start.connect(spawn_dragable)
	data.drag_stopped.connect(drag_stopped)
	data.spawn_bullet.connect(spawn_bullet)
	data.spawn_coin.connect(spawn_coin)
	data.start_game.emit()
	
func spawn_bullet(pos, trans, fruit):
	var new_bullet = bullet.instantiate()
	new_bullet.position = pos
	new_bullet.transform = trans
	new_bullet.modulate = fruit.frog_color.darkened(0.2)
	
	new_bullet.bullet_damge = fruit.bullet_damage
	new_bullet.speed = fruit.bullet_speed
	new_bullet.bullet_peice = fruit.bullet_peirce
	new_bullet.scale = Vector2(fruit.bullet_scale, fruit.bullet_scale)
	
	add_child(new_bullet)
	
func spawn_coin(pos, amount):
	for i in range(amount):
		var new_coin = coin.instantiate()
		new_coin.position = pos
		add_child(new_coin)
	
func spawn_dragable(fruit):
	var drag = drag_item.instantiate()
	drag.fruit_icon = fruit.fruit_sprite
	drag_item_layer.add_child(drag)

func drag_stopped():
	for child in drag_item_layer.get_children():
		child.queue_free()

func _on_bake_timer_timeout() -> void:
	navigation_region_2d.bake_navigation_polygon()
