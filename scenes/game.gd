extends Node2D
@onready var navigation_region_2d: NavigationRegion2D = $frogs/NavigationRegion2D
@onready var drag_item_layer: CanvasLayer = $drag_item_layer
@onready var spawn_points_node: Node2D = $spawn_points_node
@onready var enemies: Node2D = $enemies
@onready var enemy_timer: Timer = $enemy_timer
@onready var next_wave: Button = $ui/next_wave

@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var drag_item = preload("res://scenes/drag_item.tscn")
@onready var coin = preload("res://scenes/coin.tscn")
@onready var dmg_num_scene = preload("res://scenes/dmg_num.tscn")
@onready var exload_scene = preload("res://scenes/exploasion.tscn")
@onready var puddle_scene = preload("res://scenes/puddle.tscn")

@onready var spawn_points = []
var wave_enemy_list = []

func _ready() -> void:
	data.drag_item_start.connect(spawn_dragable)
	data.drag_stopped.connect(drag_stopped)
	data.spawn_bullet.connect(spawn_bullet)
	data.spawn_coin.connect(spawn_coin)
	data.dmg_num.connect(spawn_dmg_num)
	data.exploasion.connect(exploasion)
	data.spawn_puddle.connect(spawn_puddle)
	data.start_game.emit()
	
	for point in spawn_points_node.get_children():
		spawn_points.append(point)
	
	wave_enemy_list = data.shop_for_wave()
	
func spawn_dmg_num(pos, dmg):
	var num = dmg_num_scene.instantiate()
	num.text = "-" + str(dmg)
	num.position = pos
	add_child(num)
	
func spawn_puddle(pos, dmg, color):
	var puddle = puddle_scene.instantiate()
	puddle.position = pos
	puddle.modulate = color
	puddle.bullet_damge = dmg
	call_deferred("add_child", puddle)
	
func exploasion(pos):
	var exp = exload_scene.instantiate()
	exp.position = pos
	call_deferred("add_child", exp)
	#add_child(exp)
	
func _on_enemy_timer_timeout() -> void:
	for i in range(clamp(randi_range(1, round(data.wave/1)), 1, 4)):
		if wave_enemy_list.size() != 0 and data.enemy_count < data.enemy_limit:
			var ran_sp = spawn_points[randi_range(0, spawn_points.size()-1)]
			var new_enemy = wave_enemy_list[0]['preload'].instantiate()
			new_enemy.position = ran_sp.position
			new_enemy.position.x += randf_range(-30, 30)
			new_enemy.position.y += randf_range(-30, 30)
			enemies.add_child(new_enemy)
			wave_enemy_list.remove_at(0)

func _on_next_wave_pressed() -> void:
	if data.enemies_killed_this_round >= data.enemies_for_wave and data.next_wave_pressed == false:
		data.next_wave_pressed = true
		next_wave.disabled = true
		data.next_wave.emit()
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(next_wave, "scale", Vector2(0, 0), 0.3)
		#data.core_health = data.core_max_health
		data.wave += 1
		if data.wave >= 50:
			enemy_timer.wait_time = 0.01
		else:
			enemy_timer.wait_time = 0.1 - (data.wave/500)
		data.money_to_spend *= 1.15
		data.money_to_spend += 5
		#await get_tree().create_timer(5).timeout
		wave_enemy_list = data.shop_for_wave()

func spawn_bullet(pos, trans, fruit:Fruit, color):
	for bullet in fruit.bullet_scene:
		var new_bullet = bullet.instantiate()
		new_bullet.position = pos
		new_bullet.transform = trans
		new_bullet.modulate = fruit.frog_color.darkened(0.1)
		if fruit.is_rainbow:
			new_bullet.modulate = color.darkened(0.1)
		
		new_bullet.bullet_damge = fruit.bullet_damage
		new_bullet.speed = fruit.bullet_speed
		new_bullet.bullet_peice = fruit.bullet_peirce
		new_bullet.scale = Vector2(fruit.bullet_scale, fruit.bullet_scale)
		new_bullet.bounces = fruit.bounces
		new_bullet.homing = fruit.homing
		new_bullet.exploads = fruit.exploads
		new_bullet.puddle = fruit.leaves_puddles
		new_bullet.puddle_color = fruit.puddle_color
		new_bullet.puddle_dmg = fruit.puddle_dmg
		new_bullet.homing_speed = fruit.homing_speed
	
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
