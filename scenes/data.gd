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
signal dmg_num
signal wave_beat
signal next_wave
signal exploasion
signal spawn_puddle
signal settings_closed
signal settings_opened
signal tut_done

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
var next_wave_pressed:bool = false
var game_over:bool = false
var done_tut:bool = false

enum cheat_type {ALL_FRUIT, ONLY_BASE_FRUIT, NONE, DEFAULT}
var debug_type = cheat_type.DEFAULT

var coins:int = 0
var fruit_mixer_progress:int = 0

var wave:int = 0
var enemies_for_wave:int = 0
var enemies_killed_this_round:int = 0
var enemy_count:int = 0
var money_to_spend:int = 5
var money_left:int = 10
var enemy_limit:int = 1000

var enemies_killed:int = 0
var damage_done:float = 0
var bullets_shot:int = 0
var total_money:int = 0
var frogs_fed:int = 0

var fruits = [
	load("res://scenes/fruits/fire_pepper.tres"),
	load("res://scenes/fruits/ice_apple.tres"),
	load("res://scenes/fruits/electro_carrot.tres"),
	load("res://scenes/fruits/dark_matter_lemon.tres"),
	load("res://scenes/fruits/laser_egg.tres"),
	load("res://scenes/fruits/necro_bone.tres"),
	load("res://scenes/fruits/mega_fire_pepper.tres"),
	load("res://scenes/fruits/mega_ice_apple.tres"),
	load("res://scenes/fruits/mega_electro_carrot.tres"),
	load("res://scenes/fruits/bouncy_bread.tres"),
	load("res://scenes/fruits/cookie_crumbs.tres"),
	load("res://scenes/fruits/the_mega_hotdog.tres"),
	load("res://scenes/fruits/the_almighty_everything_cake.tres"),
	load("res://scenes/fruits/magma_burger_mortor.tres"),
	load("res://scenes/fruits/poison_rice.tres"),
	load("res://scenes/fruits/homing_jar.tres"),
	load("res://scenes/fruits/hydra_bacon_laser.tres"),
	load("res://scenes/fruits/magma_pizza_laser.tres"),
	load("res://scenes/fruits/photon_cheese_laser.tres"),
	load("res://scenes/fruits/acid_flask.tres"),
	load("res://scenes/fruits/rubber_waffle.tres"),
	load("res://scenes/fruits/exploading_mug.tres"),
	load("res://scenes/fruits/giga_candy_cane_laser.tres"),
	load('res://scenes/fruits/hyper_icecream.tres')
]

@onready var enemies = [
	{'wave_unlock':0, 'cost':1, 'preload':preload('res://scenes/enemies/enemy.tscn')},
	{'wave_unlock':5, 'cost':3, 'preload':preload('res://scenes/enemies/enemy_big.tscn')},
	{'wave_unlock':10, 'cost':5, 'preload':preload('res://scenes/enemies/enemy_dragon_fly.tscn')},
	{'wave_unlock':15, 'cost':10, 'preload':preload('res://scenes/enemies/enemy_dragon_fly_big.tscn')},
]

var fruits_in_mixer: Array[Fruit] = []

func find_fruit_level(fruit: Fruit) -> int:
	if fruit.recipe_to_make == null:
		return 1
	var total_steps :float= 1.1
	for ingredient in fruit.recipe_to_make.fruits_needed:
		total_steps += find_fruit_level(ingredient)
	fruit.level = total_steps
	return total_steps

func get_rand_fruit_weighted():
	var calculated_weights = []
	for fruit in fruits:
		var level = find_fruit_level(fruit)
		var weight = 1.0 / (level)
		calculated_weights.append(weight)

	return weighted_random(fruits, calculated_weights)

############################################

func weighted_random(items: Array, weights: Array):

	var total_weight = 0.0
	for weight in weights:
		total_weight += weight

	var rand = randf() * total_weight
	var cumulative_weight = 0.0

	for i in range(items.size()):
		cumulative_weight += weights[i]
		if rand < cumulative_weight:
			return items[i]

	return items[-1]

func test_rand_weights():
	var fruit_list = []
	var tests:float = 10000
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
	fruits.sort_custom(fruit_level_sort)
	#test_rand_weights()

func fruit_level_sort(a, b):
	if find_fruit_level(a) < find_fruit_level(b):
		return true
	return false

#func _process(delta: float) -> void:
	#pass

func shop_for_wave():
	money_left = money_to_spend
	var enemy_list = []
	while money_left > 0:
		var attemt = enemies[randi_range(0, enemies.size()-1)]
		if attemt.cost <= money_left and attemt.wave_unlock <= wave:
			money_left -= attemt.cost
			enemy_list.append(attemt)
	enemies_killed_this_round = 0
	enemies_for_wave = enemy_list.size()
	enemy_count = enemies_for_wave
	return enemy_list
	
func format_number_with_commas(number: int) -> String:
	var num_str = str(number)
	var formatted_str = ""
	var length = num_str.length()
	var first_group_len = length % 3

	if first_group_len == 0:
		first_group_len = 3

	formatted_str += num_str.substr(0, first_group_len)

	for i in range(first_group_len, length, 3):
		formatted_str += "," + num_str.substr(i, 3)

	return formatted_str
