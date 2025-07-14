extends Node

signal drag_item_start
signal drag_stopped
signal tab_change
signal spawn_bullet
signal spawn_coin
signal start_game
signal inspect_fruit
signal mixer_updated
signal mixer_able_to_mix

var holding_fruit:bool = false
var flag_pos:Vector2 = Vector2.ZERO
var health:float = 100
var mouse_down:float = false
var item_seletecd:Fruit
var item_inspect_selected:Fruit
var tab_selected:String = 'Fruits'

var coins:int = 0
var fruit_mixer_progress:int = 0

var fruits = [
	load("res://scenes/fruits/fire_pepper.tres"),
	load("res://scenes/fruits/ice_apple.tres"),
	load("res://scenes/fruits/electro_carrot.tres"),
	load("res://scenes/fruits/dark_matter_lemon.tres"),
	load("res://scenes/fruits/laser_egg.tres"),
]

var fruits_in_mixer: Array[Fruit] = []
