extends Control
@onready var eyeball_left: Panel = %eyeball_left
@onready var eyeball_right: Panel = %eyeball_right
@onready var nav_mesh: Polygon2D = $nav_mesh
@onready var outline: TextureRect = $outline
@onready var mouth_open: Panel = $frog_sprite/mouth_open
@onready var mouth_smile: Line2D = $frog_sprite/mouth_smile
@onready var marker_2d: Marker2D = $Marker2D
@onready var shoot_timer: Timer = $shoot_timer
@onready var click_detect: Button = $click_detect
@onready var fruit_belly_icon: TextureRect = $frog_sprite/belly/fruit_icon
@onready var frog_sprite: Control = $frog_sprite
@onready var close_mouth: Timer = $close_mouth

@export var is_hidden:bool = false
@export var hover_outline:bool = true

var times_pressed = 0
var follow_cursor = true
var hovered = false

var shooting = false
var enemies_in_range = []
var target_enemy = 0

var attack_speed = 1
@onready var bullet_spawners = [marker_2d]

var fruit_eaten:Fruit

func _ready() -> void:
	if is_hidden:
		modulate.a = 0
		for child in get_children():
			child.queue_free()
	if hover_outline == false:
		outline.hide()
	if is_hidden == false:
		data.drag_stopped.connect(check_if_on_frog)
		await get_tree().create_timer(randf_range(0.1, 2)).timeout

func _physics_process(_delta: float) -> void:
	if is_hidden == false:
		click_detect.visible = !data.holding_fruit
		
		if is_hidden and nav_mesh:
			nav_mesh.queue_free()
		
		for enemy in enemies_in_range:
			if enemy:
				shooting = true
		
		if enemies_in_range.size() != 0:
			for marker in bullet_spawners:
				marker.rotation = (enemies_in_range[target_enemy].global_position - marker.global_position).angle()
		
		if follow_cursor and is_hidden == false:
			
			var look_scale = 3
			var offset = Vector2(4, 7)
			
			if global_position.distance_to(get_global_mouse_position()) < 200:
				
				var target_pos_left = eyeball_left.global_position.direction_to(get_global_mouse_position())*look_scale
				eyeball_left.position = lerp(eyeball_left.position, Vector2(target_pos_left.x+offset.x, target_pos_left.y+offset.y), 0.5)
				
				var target_pos_right = eyeball_right.global_position.direction_to(get_global_mouse_position())*look_scale
				eyeball_right.position = lerp(eyeball_right.position, Vector2(target_pos_right.x+offset.x, target_pos_right.y+offset.y), 0.5)
			else:
				if fruit_eaten != null and enemies_in_range.size() != 0:
					var target = enemies_in_range[target_enemy].global_position
					
					var target_pos_left = eyeball_left.global_position.direction_to(target)*look_scale
					eyeball_left.position = lerp(eyeball_left.position, Vector2(target_pos_left.x+offset.x, target_pos_left.y+offset.y), 0.5)
				
					var target_pos_right = eyeball_right.global_position.direction_to(target)*look_scale
					eyeball_right.position = lerp(eyeball_right.position, Vector2(target_pos_right.x+offset.x, target_pos_right.y+offset.y), 0.5)
					
				else:
					var target_pos_left = Vector2.ZERO
					eyeball_left.position = lerp(eyeball_left.position, Vector2(target_pos_left.x+offset.x, target_pos_left.y+offset.y), 0.5)
					
					var target_pos_right = Vector2.ZERO
					eyeball_right.position = lerp(eyeball_right.position, Vector2(target_pos_right.x+offset.x, target_pos_right.y+offset.y), 0.5)

func _on_mouse_entered() -> void:
	if is_hidden == false:
		hovered = true
		if data.holding_fruit:
			mouth_open.show()
			mouth_smile.hide()
			var t = create_tween().set_trans(Tween.TRANS_CIRC)
			t.tween_property(outline, "scale", Vector2(2.145, 2.145), 0.1)

func _on_mouse_exited() -> void:
	if is_hidden == false:
		hovered = false
		mouth_open.hide()
		mouth_smile.show()
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(outline, "scale", Vector2(0, 0), 0.1)

func check_if_on_frog():
	mouth_open.hide()
	mouth_smile.show()
	if hovered:
		if randi_range(0,1)==0:
			SoundManager.play_sound('frog_eat', randf_range(0.9, 1.1), 0)
		else:
			SoundManager.play_sound('frog_eat2', randf_range(0.9, 1.1), 0)
		fruit_eaten = data.item_seletecd
		
		fruit_eaten.fruit_count -= 1
		data.remove_fruit_from_inv.emit(fruit_eaten)
		
		# apply food
		frog_sprite.modulate = fruit_eaten.frog_color
		fruit_belly_icon.texture = fruit_eaten.belly_icon
		shoot_timer.start(fruit_eaten.attack_speed)

func _on_shoot_timer_timeout() -> void:
	if shooting and enemies_in_range.is_empty() == false and fruit_eaten != null:
		for spawner in bullet_spawners:
			if fruit_eaten.bullet_spread != 0:
				spawner.rotation_degrees -= (fruit_eaten.bullet_spread * (fruit_eaten.bullets_shot+1))/2
			for i in range(fruit_eaten.bullets_shot):
				spawner.rotation_degrees += fruit_eaten.bullet_spread
				data.spawn_bullet.emit(spawner.global_position, spawner.global_transform, fruit_eaten)
				SoundManager.play_sound("shoot", randf_range(0.8, 1.2), -15)
				mouth_open.show()
				mouth_smile.hide()
				
				close_mouth.start()

func _on_enemy_detect_body_entered(body: Node2D) -> void:
	enemies_in_range.append(body)

func _on_enemy_detect_body_exited(body: Node2D) -> void:
	enemies_in_range.remove_at(enemies_in_range.find(body))

func _on_click_detect_pressed() -> void:
	times_pressed += 1
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	if randi_range(0,1) == 0:
		SoundManager.play_sound('squeak2', randf_range(0.8, 1.2), -10)
	else:
		SoundManager.play_sound('squeak2', randf_range(0.8, 1.2), -10)
	if randi_range(0,1) == 0:
		t.tween_property(self, "scale", Vector2(1,1.2), 0.1)
	else:
		t.tween_property(self, "scale", Vector2(1.2,1), 0.1)
	t.chain().tween_property(self, "scale", Vector2(1,1), 0.1)
	
	#if times_pressed >= 30:
		#SoundManager.play('angry_frog', randf_range(0.8, 1.2), 0)

func _on_times_pressed_reset_timeout() -> void:
	times_pressed = 0


func _on_close_mouth_timeout() -> void:
	mouth_open.hide()
	mouth_smile.show()
