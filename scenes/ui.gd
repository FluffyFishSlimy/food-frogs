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
	
	# Add recipies
	for fruit in data.fruits:
		var new_fruit_item = fruit_item.instantiate()
		new_fruit_item.fruit_type = fruit
		new_fruit_item.is_recipe = true
		recipe_container.add_child(new_fruit_item)

func mix_btn_update(is_mixable, fruit):
	mix_btn.disabled = !is_mixable

func open_recipe_info():
	recipes_open = true
	
	recipe_display_fruit.fruit_type = data.item_inspect_selected
	#recipe_display_fruit.recipe_discovered = data.item_inspect_selected.has_been_discovered
	recipe_display_fruit.update_info()
	recipe_display_fruit.update_recipe_item()
	
	fruit_name.text = data.item_inspect_selected.name
	fruit_desc.text = data.item_inspect_selected.desc
	
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

func chage_tabs():
	# Hide all otehr tabs firs
	fruit_container.hide()
	lab_stuff.hide()
	recipe_container.hide()
	recipe_info.hide()
	scroll_container.size.y = 368 # 580 
	scroll_container.scroll_vertical = 0
	
	# Show the selected Tab
	if data.tab_selected == "Fruits":
		fruit_container.show()
		lab_stuff.show()
		scroll_container.size.y = 368
	if data.tab_selected == "Recipe Book":
		if recipes_open:
			recipe_info.show()
		else:
			recipe_container.show()
	
func _physics_process(_delta: float) -> void:
	health_bar.value = lerp(health_bar.value, data.health, 0.2)
	percentage.text = "Health: " + str(clamp(int(round(data.health)), 0, 100)) + "%"

func add_button_animations():
	var buttons = [
		settings_button,
		mix_btn,
		back_btn
	]
	for button in buttons:
		button.pivot_offset = Vector2(button.size.x/2, button.size.y/2)
		button.mouse_entered.connect(button_scale_up.bind(button))
		button.mouse_exited.connect(button_scale_down.bind(button))
		button.button_down.connect(button_down_pressed.bind(button))
		button.button_up.connect(button_released.bind(button))

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
	recipe_container.show()
	recipe_info.hide()
