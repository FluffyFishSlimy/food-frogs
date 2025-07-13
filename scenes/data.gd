extends Node

signal drag_item_start
signal drag_stopped
signal tab_change
signal spawn_bullet
signal spawn_coin
signal start_game

var holding_fruit:bool = false
var flag_pos:Vector2 = Vector2.ZERO
var health:float = 100
var mouse_down:float = false
var item_seletecd:Fruit
var tab_selected = 'Fruits'

var coins:int = 0

var fruits = [
	load("res://scenes/fruits/hot_pepper.tres"),
	load("res://scenes/fruits/ice_apple.tres"),
	load("res://scenes/fruits/electro_carrot.tres"),
	load("res://scenes/fruits/dark_matter_lemon.tres"),
]
