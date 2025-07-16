extends Control
@onready var path_2d: Path2D = $Path2D
@onready var mixer_sprite_outline: TextureRect = $mixer_sprite_outline
@onready var animation_player: AnimationPlayer = $mixer_sprite/AnimationPlayer

var potion_fruit = preload("res://scenes/potion_fruit.tscn")
var hovering = false

func _ready() -> void:
	data.drag_stopped.connect(check_if_hovered)
	data.mixer_updated.connect(check_if_recipe)
	data.mix.connect(mix)
	
func mix():
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(animation_player, "speed_scale", 1, 1)
	await get_tree().create_timer(1).timeout
	var t2 = create_tween().set_trans(Tween.TRANS_CIRC)
	t2.tween_property(animation_player, "speed_scale", 0.1, 1)
	
	var fruit_first
	var mixer_size = data.fruits_in_mixer.size()
	data.fruits_in_mixer = []
	if path_2d.get_children()[0]:
		fruit_first = path_2d.get_children()[0].fruit_type
		
	for fruit in path_2d.get_children():
		fruit.delete_fruit()
	
	await get_tree().create_timer(0.8).timeout
	#data.add_fruit_to_inv.emit(data.mix_fruit)
	
	if mixer_size == 1 and fruit_first.recipe_to_make != null:
		for fruit in fruit_first.recipe_to_make.fruits_needed:
			data.fruits_in_mixer.append(fruit)
			add_fruit(fruit, true)
			fruit.has_been_discovered = true
	else:
		data.fruits_in_mixer.append(data.mix_fruit)
		add_fruit(data.mix_fruit, true)
		if data.mix_fruit.has_been_discovered == false:
			data.update_tab_badge.emit('Recipe Book', true)
			data.new_fruit_badge.emit(data.mix_fruit)
		data.mix_fruit.has_been_discovered = true
	
	data.mixer_updated.emit()
	data.mixing = false
	data.mixing_done.emit()

func add_fruit(fruit, new):
	var new_fruit = potion_fruit.instantiate()
	new_fruit.fruit_type = fruit
	if new == false:
		fruit.fruit_count -= 1
	data.remove_fruit_from_inv.emit(fruit)
	SoundManager.play_sound('water_plop', randf_range(0.7, 1.3), 0)
	path_2d.add_child(new_fruit)

func check_if_hovered():
	if hovering and data.mixing == false:
		add_fruit(data.item_seletecd, false)
		data.fruits_in_mixer.append(data.item_seletecd)
		data.mixer_updated.emit()

func check_if_recipe():
	if data.fruits_in_mixer.size() > 1:
		data.mix_mode = 'Mix'
		var found_recipe = false
		for fruit in data.fruits:
			if fruit.recipe_to_make:
				if lists_have_same_named_objects(data.fruits_in_mixer, fruit.recipe_to_make.fruits_needed):
					found_recipe = true
					data.mix_fruit = fruit
					data.mixer_able_to_mix.emit(true, fruit)
		if found_recipe == false:
			data.mixer_able_to_mix.emit(false, null)
	else:
		if data.fruits_in_mixer.size() == 1:
			if data.fruits_in_mixer[0].recipe_to_make != null:
				data.mixer_able_to_mix.emit(true, data.fruits_in_mixer[0])
				data.mix_mode = 'Unmix'
			else:
				data.mixer_able_to_mix.emit(false, null)
		else:
			data.mix_mode = 'Mix'
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
	if data.holding_fruit and data.mixing == false:
		var t = create_tween().set_trans(Tween.TRANS_CIRC)
		t.tween_property(mixer_sprite_outline, "scale", Vector2(1, 1), 0.2)

func _on_mouse_exited() -> void:
	hovering = false
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(mixer_sprite_outline, "scale", Vector2(0, 0), 0.2)
