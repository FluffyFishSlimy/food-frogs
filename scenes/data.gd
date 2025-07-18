extends Node

signal drag_item_start
signal drag_stopped
signal tab_change
signal spawn_bullet
signal spawn_coin
signal coin_picked_up
signal start_game
signal inspect_fruit
signal mixer_updated
signal mixer_able_to_mix
signal add_fruit_to_inv
signal remove_fruit_from_inv
signal mix
signal mixing_done
signal update_tab_badge
signal new_fruit_badge
signal open_box

var holding_fruit:bool = false
var flag_pos:Vector2 = Vector2.ZERO
var health:float = 100
var mouse_down:float = false
var item_seletecd:Fruit
var item_inspect_selected:Fruit
var tab_selected:String = 'Fruits'
var mix_fruit:Fruit
var mixing:bool = false
var mix_mode:String = "Mix"
var is_opening_box:bool = false

enum cheat_type {ALL_FRUIT, ONLY_BASE_FRUIT, NONE}
var debug_type = cheat_type.ONLY_BASE_FRUIT

var coins:int = 1000
var wave:int = 0
var fruit_mixer_progress:int = 0

var fruits = [
	load("res://scenes/fruits/fire_pepper.tres"),
	load("res://scenes/fruits/ice_apple.tres"),
	load("res://scenes/fruits/electro_carrot.tres"),
	load("res://scenes/fruits/dark_matter_lemon.tres"),
	load("res://scenes/fruits/laser_egg.tres"),
	load("res://scenes/fruits/necro_bone.tres"),
	load("res://scenes/fruits/mega_fire_pepper.tres")
]

var fruits_in_mixer: Array[Fruit] = []

func find_fruit_level(fruit: Fruit) -> int:
	if fruit.recipe_to_make == null:
		return 1

	var total_steps := 1

	for ingredient in fruit.recipe_to_make.fruits_needed:
		total_steps += find_fruit_level(ingredient)
	
	fruit.level = total_steps
	return total_steps

func get_rand_fruit_weighted():
	var list_of_weights = []
	var largest_weight = 0
	for fruit in fruits:
		var weight = find_fruit_level(fruit)
		if weight > largest_weight:
			largest_weight = weight
		list_of_weights.append(weight)
	
	for i in range(list_of_weights.size()):
		list_of_weights[i] = (largest_weight + 1) - list_of_weights[i]
	
	return weighted_random(fruits, list_of_weights)
	
func weighted_random(items, weights):
	var total := 0
	for weight in weights:
		total += weight
		
	var threshold := randf() * total

	var sum = 0;
	for i in range(items.size()):
		sum += weights[i];
		if threshold < sum:
			return items[i];

func test_rand_weights():
	var fruit_list = []
	var tests:float = 100000
	for i in range(tests):
		var fruit = get_rand_fruit_weighted().name
		var found = false
		for item in fruit_list:
			if item.name == fruit:
				item.count += 1
				found = true
		if found == false:
			fruit_list.append({"name":fruit, "count":1.0})
	
	print("Weights Test Results x" + str(int(tests)) + " Runs ---------\n")
	fruit_list.sort_custom(most_fruit)
	for item in fruit_list:
		print(str(int(item.count)) + " | " + str((float(item.count)/tests)*100).substr(0, 4) + "%  -  " + item.name)

func most_fruit(a, b):
	if b.count < a.count:
		return true
	return false

func _ready() -> void:
	#test_rand_weights()
	pass

#func _process(delta: float) -> void:
	#pass
