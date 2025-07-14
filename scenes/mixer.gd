extends Control
@onready var path_2d: Path2D = $Path2D
@onready var mixer_sprite_outline: TextureRect = $mixer_sprite_outline

var potion_fruit = preload("res://scenes/potion_fruit.tscn")
var hovering = false

func _ready() -> void:
	data.drag_stopped.connect(check_if_hovered)
	data.mixer_updated.connect(check_if_recipe)

func add_fruit(fruit):
	var new_fruit = potion_fruit.instantiate()
	new_fruit.fruit_type = fruit
	SoundManager.play_sound('water_plop', randf_range(0.7, 1.3), 0)
	path_2d.add_child(new_fruit)

func check_if_hovered():
	if hovering:
		add_fruit(data.item_seletecd)
		data.fruits_in_mixer.append(data.item_seletecd)
		data.mixer_updated.emit()

func check_if_recipe():
	var found_recipe = false
	for fruit in data.fruits:
		if fruit.recipe_to_make:
			if lists_have_same_named_objects(data.fruits_in_mixer, fruit.recipe_to_make.fruits_needed):
				found_recipe = true
				data.mixer_able_to_mix.emit(true, fruit)
	if found_recipe == false:
		data.mixer_able_to_mix.emit(false, null)

func lists_have_same_named_objects(list_a: Array, list_b: Array) -> bool:
	var names_a := []
	var names_b := []

	for obj in list_a:
		names_a.append(obj.name)

	for obj in list_b:
		names_b.append(obj.name)

	# Sort the name lists so that order doesn't matter
	names_a.sort()
	names_b.sort()

	return names_a == names_b


func _on_mouse_entered() -> void:
	hovering = true
	if data.holding_fruit:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(mixer_sprite_outline, "scale", Vector2(1, 1), 0.2)

func _on_mouse_exited() -> void:
	hovering = false
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(mixer_sprite_outline, "scale", Vector2(0, 0), 0.2)
