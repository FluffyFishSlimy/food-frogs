extends Button
@onready var fruit_icon: TextureRect = $fruit_icon
@onready var count: Label = $count
@onready var question_marks: Label = $question_marks
@onready var one_question_mark: Label = $one_question_mark
@onready var cost_price: Label = $cost_price
@onready var badge: Panel = $badge

var wiggle_button_object = null
var fruit_type:Fruit = data.fruits[randi_range(0, data.fruits.size()-1)]
@export var is_recipe:bool = false
var is_mini_recipe:bool = false
@export var recipe_discovered = false
@export var is_big_display:bool = false
@export var show_just_question_mark:bool = false
@export var is_shop_item:bool = false
@export var override_icon:CompressedTexture2D
var new_fruit = false

func _ready() -> void:
	add_button_animations()
	update_info(fruit_type)
	data.add_fruit_to_inv.connect(update_info)
	data.remove_fruit_from_inv.connect(update_info)
	
	if is_mini_recipe:
		count.hide()
		update_mini_recipe()
		data.tab_change.connect(update_mini_recipe)
		
	if is_shop_item:
		count.hide()
		cost_price.show()
	
	if is_recipe:
		count.hide()
		data.tab_change.connect(update_recipe_item)
		data.new_fruit_badge.connect(show_badge)

func show_badge(fruit):
	if fruit_type == fruit:
		new_fruit = true
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(badge, 'scale', Vector2(1, 1), 0.3)

func update_mini_recipe():
	recipe_discovered = data.item_inspect_selected.has_been_discovered
	if recipe_discovered == false:
		one_question_mark.show()
		fruit_icon.hide()
	else:
		fruit_icon.modulate = Color.WHITE
		fruit_icon.show()
		question_marks.hide()
		one_question_mark.hide()

func update_recipe_item():
	if fruit_type.has_been_discovered == false:
		fruit_icon.modulate = Color.BLACK
		if !show_just_question_mark:
			question_marks.show()
		if show_just_question_mark:
			one_question_mark.show()
			fruit_icon.hide()
	else:
		fruit_icon.modulate = Color.WHITE
		fruit_icon.show()
		question_marks.hide()
		one_question_mark.hide()

func update_info(_fruit):
	if override_icon:
		fruit_icon.texture = override_icon
	else:
		fruit_icon.texture = fruit_type.fruit_sprite
	count.text = "x" + str(fruit_type.fruit_count)
	
	if fruit_type.fruit_count <= 0:
		if is_mini_recipe or is_recipe or is_shop_item:
			pass
		else:
			queue_free()

func add_button_animations():
	var buttons = [
		self
	]
	for button in buttons:
		button.pivot_offset = Vector2(button.size.x/2, button.size.y/2)
		button.mouse_entered.connect(button_scale_up.bind(button))
		button.mouse_exited.connect(button_scale_down.bind(button))
		button.button_down.connect(button_down_pressed.bind(button))
		button.button_up.connect(button_released.bind(button))
		#button.pressed.connect(button_click_sound.bind(button))

func button_scale_up(button):
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
	wiggle_button_object = button
	SoundManager.play_sound("button_hover", randf_range(0.9, 1.1), 0)

func button_scale_down(button):
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
	if !is_recipe and !is_mini_recipe and !is_shop_item:
		modulate.a = 0.5
		data.drag_item_start.emit(fruit_type)
		data.holding_fruit = true
		data.item_seletecd = fruit_type
	SoundManager.play_sound("button_press", randf_range(0.8, 1.2), 0)
	
func button_released(button):
	#print('Is recipe: '+str(is_recipe))
	#print('Is recipe discovered: '+str(recipe_discovered))
	
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	if !is_recipe and !is_mini_recipe and !is_shop_item:
		modulate.a = 1
		data.drag_stopped.emit()
		data.holding_fruit = false
	else:
		if !is_big_display and !show_just_question_mark and !is_shop_item:
			if new_fruit:
				new_fruit = false
				var t2 = create_tween().set_trans(Tween.TRANS_CIRC)
				t2.tween_property(badge, 'scale', Vector2(0, 0), 0.3)
			data.item_inspect_selected = fruit_type
			data.inspect_fruit.emit()
		if is_mini_recipe and recipe_discovered:
			data.item_inspect_selected = fruit_type
			data.inspect_fruit.emit()
	t.tween_property(button, "scale", Vector2(1, 1), 0.1)

func _on_button_rotate_timeout() -> void:
	if wiggle_button_object != null:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(wiggle_button_object, "rotation", 0.05, 0.2)
		t.chain().tween_property(wiggle_button_object, "rotation", -0.05, 0.2)
