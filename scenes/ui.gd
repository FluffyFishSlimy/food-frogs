extends CanvasLayer
@onready var transition: ColorRect = $transition
@onready var percentage: Label = $health/percentage
@onready var health_bar: ProgressBar = $health
@onready var settings_button: Button = $settings
@onready var fruit_container: GridContainer = $fruit_panel/ScrollContainer/fruit_container
@onready var scroll_container: ScrollContainer = $fruit_panel/ScrollContainer
@onready var mixer: Control = $fruit_panel/lab_stuff/mixer
@onready var mix_btn: Button = $fruit_panel/lab_stuff/mix_btn
@onready var lab_stuff: Control = $fruit_panel/lab_stuff
@onready var recipe_container: GridContainer = $fruit_panel/ScrollContainer/recipe_container
@onready var recipe_info: Control = $fruit_panel/recipe_info
@onready var back_btn: Button = $fruit_panel/recipe_info/VBoxContainer/back_btn
@onready var recipe_display_fruit: Button = $fruit_panel/recipe_info/VBoxContainer/fruit_item
@onready var fruit_name: Label = $fruit_panel/recipe_info/VBoxContainer/fruit_name
@onready var fruit_desc: Label = $fruit_panel/recipe_info/VBoxContainer/desc
@onready var recipe_guide: GridContainer = $fruit_panel/recipe_info/VBoxContainer/recipe_guide
@onready var made_with: Label = $fruit_panel/recipe_info/VBoxContainer/made_with
@onready var shop_stuff: Control = $fruit_panel/shop
@onready var coins_num: Label = $stats_container/coins_num
@onready var coins_panel: = coins_num
@onready var box_opening: Control = $fruit_panel/box_opening
@onready var scroll_wheel: VBoxContainer = $fruit_panel/box_opening/scroll_wheel_clip/scroll_wheel
@onready var next_wave: Button = $next_wave
@onready var wave_num: Label = $stats_container/wave_num
@onready var shop_item_container: GridContainer = $fruit_panel/shop/VBoxContainer/item_container

@onready var fruit_item = preload("res://scenes/fruit_item.tscn")

var wiggle_button_object
var recipes_open = false

func _ready() -> void:
	
	transition.show()
	add_button_animations()
	data.tab_change.connect(chage_tabs)
	data.tab_change.emit()
	data.inspect_fruit.connect(open_recipe_info)
	data.mixer_able_to_mix.connect(mix_btn_update)
	data.add_fruit_to_inv.connect(add_fruit_to_inv)
	data.mixer_updated.connect(mix_or_unmix)
	data.mixing_done.connect(update_recipe_info)
	data.coin_picked_up.connect(bump_coin_counter)
	data.open_box.connect(open_box)
	data.spawn_coin.connect(check_if_wave_over)
	data.next_wave.connect(refresh_shop)
	
	# Manually add in some fruits
	if data.debug_type== data.cheat_type.ALL_FRUIT:
		for fruit in data.fruits:
			for i in range(30):
				data.add_fruit_to_inv.emit(fruit)
	if data.debug_type == data.cheat_type.ONLY_BASE_FRUIT:
		for i in range(30):
			data.add_fruit_to_inv.emit(data.fruits[0])
			data.add_fruit_to_inv.emit(data.fruits[1])
			data.add_fruit_to_inv.emit(data.fruits[2])
	if data.debug_type == data.cheat_type.DEFAULT:
		data.add_fruit_to_inv.emit(data.fruits[0])
		data.add_fruit_to_inv.emit(data.fruits[1])
		data.add_fruit_to_inv.emit(data.fruits[2])
	
	# Add recipies
	for fruit in data.fruits:
		var new_fruit_item = fruit_item.instantiate()
		new_fruit_item.fruit_type = fruit
		new_fruit_item.is_recipe = true
		recipe_container.add_child(new_fruit_item)

func refresh_shop():
	for c in shop_item_container.get_children():
		c.queue_free()
	
	for i in range(6):
		var new_shop_item = fruit_item.instantiate()
		new_shop_item.is_shop_item = true
		shop_item_container.add_child(new_shop_item)
		new_shop_item.update_info(new_shop_item.fruit_type)

func check_if_wave_over(pos, value):
	if data.enemy_count <= 0:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		data.next_wave_pressed = false
		data.wave_beat.emit()
		next_wave.disabled = false
		t.tween_property(next_wave, "scale", Vector2(1, 1), 0.5)

func add_fruit_to_inv(fruit):
	fruit.has_been_discovered = true
	if fruit.fruit_count <= 0:
		fruit.fruit_count += 1
		var new_fruit = fruit_item.instantiate()
		new_fruit.fruit_type = fruit
		fruit_container.add_child(new_fruit)
	else:
		fruit.fruit_count += 1

func mix_or_unmix():
	mix_btn.text = data.mix_mode

func mix_btn_update(is_mixable, fruit):
	mix_btn.disabled = !is_mixable
	mix_btn.text = data.mix_mode

func update_recipe_info():
	if data.item_inspect_selected:
		recipe_display_fruit.fruit_type = data.item_inspect_selected
		#recipe_display_fruit.recipe_discovered = data.item_inspect_selected.has_been_discovered
		recipe_display_fruit.update_info(null)
		recipe_display_fruit.update_recipe_item()
		
		if data.item_inspect_selected.has_been_discovered:
			fruit_name.text = data.item_inspect_selected.name
			fruit_desc.text = data.item_inspect_selected.desc
		else:
			fruit_name.text = "???"
			fruit_desc.text = "Discover this recipe to learn more"
		
		for child in recipe_guide.get_children():
			child.queue_free()
		
		if data.item_inspect_selected.recipe_to_make:
			made_with.text = "Made With"
			
			for fruit in data.item_inspect_selected.recipe_to_make.fruits_needed:
				var new_requirement = fruit_item.instantiate()
				new_requirement.fruit_type = fruit
				new_requirement.is_mini_recipe = true
				new_requirement.is_big_display = false
				new_requirement.show_just_question_mark = true
				new_requirement.recipe_discovered = data.item_inspect_selected.has_been_discovered
				new_requirement.custom_minimum_size = Vector2(40, 40)
				recipe_guide.add_child(new_requirement)
		else:
			made_with.text = "Made With\nNothing"
	

func open_recipe_info():
	recipes_open = true
	
	recipe_display_fruit.fruit_type = data.item_inspect_selected
	#recipe_display_fruit.recipe_discovered = data.item_inspect_selected.has_been_discovered
	recipe_display_fruit.update_info(null)
	recipe_display_fruit.update_recipe_item()
	
	if data.item_inspect_selected.has_been_discovered:
		fruit_name.text = data.item_inspect_selected.name
		fruit_desc.text = data.item_inspect_selected.desc
	else:
		fruit_name.text = "???"
		fruit_desc.text = "Discover this recipe to learn more"
	
	for child in recipe_guide.get_children():
		child.queue_free()
	
	if data.item_inspect_selected.recipe_to_make:
		made_with.text = "Made With"
		
		for fruit in data.item_inspect_selected.recipe_to_make.fruits_needed:
			var new_requirement = fruit_item.instantiate()
			new_requirement.fruit_type = fruit
			new_requirement.is_mini_recipe = true
			new_requirement.is_big_display = false
			new_requirement.show_just_question_mark = true
			new_requirement.recipe_discovered = data.item_inspect_selected.has_been_discovered
			new_requirement.custom_minimum_size = Vector2(40, 40)
			recipe_guide.add_child(new_requirement)
	else:
		made_with.text = "Made With\nNothing"
	
	recipe_container.hide()
	recipe_info.show()

func open_box():
	var not_gotten_fruit = []
	
	scroll_wheel.position.y = -29
	var fruit_gotten
	
	for child in scroll_wheel.get_children():
		child.queue_free()
	for i in range(46):
		var new_fruit = fruit_item.instantiate()
		new_fruit.fruit_type = data.get_rand_fruit_weighted()
		new_fruit.is_recipe = true
		new_fruit.recipe_discovered = true
		new_fruit.box_item = true
		if i == 40:
			fruit_gotten = new_fruit
			new_fruit.is_box_reward = true
		else:
			not_gotten_fruit.append(new_fruit)
		scroll_wheel.add_child(new_fruit)
		
		
	shop_stuff.hide()
	box_opening.show()
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	var target_y = -2583.0

	# Tween the position over 2 seconds
	t.tween_method(_update_scroll_y, scroll_wheel.position.y, target_y, 2)
	await t.finished
	
	for fruit_item in not_gotten_fruit:
		#fruit_item.disabled = true
		var t2 = create_tween().set_trans(Tween.TRANS_CIRC)
		t2.tween_property(fruit_item, "modulate", Color("#bababa"), 0.3)
	
	SoundManager.play_sound('mixer_ding', randf_range(0.9, 1.1), 0)
	await get_tree().create_timer(0.3).timeout

var last_sound_y = -29
var sound_interval = 65

func _update_scroll_y(value):
	scroll_wheel.position.y = value
	if abs(value - last_sound_y) >= sound_interval:
		last_sound_y = value
		SoundManager.play_sound("button_hover", randf_range(0.9, 1.1), 0)

func chage_tabs():
	# Hide all otehr tabs firs
	fruit_container.hide()
	lab_stuff.hide()
	recipe_container.hide()
	recipe_info.hide()
	shop_stuff.hide()
	box_opening.hide()
	scroll_container.size.y = 368 # 580 
	scroll_container.scroll_vertical = 15
	
	# Show the selected Tab
	if data.tab_selected == "Fruits":
		scroll_container.scroll_vertical = 15
		fruit_container.show()
		lab_stuff.show()
		scroll_container.size.y = 368
	if data.tab_selected == "Recipe Book":
		scroll_container.scroll_vertical = 15
		
		if recipes_open:
			recipe_info.show()
		else:
			recipe_container.show()
		scroll_container.size.y = 580 # 580 
	if data.tab_selected == "Shop":
		if data.is_opening_box:
			box_opening.show()
		else:
			shop_stuff.show()
	
func _physics_process(_delta: float) -> void:
	health_bar.value = lerp(health_bar.value, data.health, 0.2)
	percentage.text = "Health: " + str(clamp(int(round(data.health)), 0, 100)) + "%"
	coins_num.text = "¢" + data.format_number_with_commas(data.coins)
	wave_num.text = "Wave " + str(data.wave+1)
	
func add_button_animations():
	var buttons = [
		settings_button,
		mix_btn,
		back_btn,
		next_wave
	]
	for button in buttons:
		button.pivot_offset = Vector2(button.size.x/2, button.size.y/2)
		button.mouse_entered.connect(button_scale_up.bind(button))
		button.mouse_exited.connect(button_scale_down.bind(button))
		button.button_down.connect(button_down_pressed.bind(button))
		button.button_up.connect(button_released.bind(button))

func bump_coin_counter():
	coins_panel.pivot_offset = Vector2(coins_panel.size.x/2, coins_panel.size.y/2)
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(coins_panel, "scale", Vector2(1.1, 1.1), 0.2)
	t.chain().tween_property(coins_panel, "scale", Vector2(1, 1), 0.2)

func button_scale_up(button):
	if !button.disabled:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
		wiggle_button_object = button
		SoundManager.play_sound("button_hover", randf_range(0.9, 1.1), 0)

func button_scale_down(button):
	if !button.disabled:
		wiggle_button_object = null
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
		t.tween_property(button, "rotation", 0, 0.2)

func button_click_sound(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(0.85, 0.85), 0.1)
	t.chain().tween_property(button, "scale", Vector2(1, 1), 0.1)
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)

func button_down_pressed(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(0.85, 0.85), 0.1)
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)
	
func button_released(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(1, 1), 0.1)

func _on_button_rotate_timeout() -> void:
	if wiggle_button_object != null:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(wiggle_button_object, "rotation", 0.05, 0.2)
		t.chain().tween_property(wiggle_button_object, "rotation", -0.05, 0.2)

func _on_back_btn_pressed() -> void:
	recipes_open = false
	data.tab_selected = 'Recipe Book'
	data.tab_change.emit()
	#recipe_container.show()
	#recipe_info.hide()

func _on_mix_btn_button_up() -> void:
	if data.mixing == false:
		data.mixing = true
		data.mix.emit()
		data.mixer_updated.emit()
		data.mixer_able_to_mix.emit(false, null)


#func _on_next_wave_mouse_entered() -> void:
	#if data.holding_fruit:
		#next_wave.modulate.a = 0.3
		#next_wave.mouse_filter = Control.MOUSE_FILTER_IGNORE
#
#func _on_next_wave_mouse_exited() -> void:
	#next_wave.modulate.a = 1
