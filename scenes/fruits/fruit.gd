class_name Fruit
extends Resource

@export_category('Basic Info')
@export var name: String = 'Fruit Name'
@export var desc:String = "Fruit Description"
var level:int = -1
@export var fruit_sprite:CompressedTexture2D
@export var frog_color:Color
@export var is_rainbow:bool = false
@export var show_rainbow_outline:bool = false
@export var belly_icon:CompressedTexture2D
@export var cost:int = 5
@export var has_been_discovered:bool = false
var fruit_count:int = 0
@export var recipe_to_make:Recipe

@export_category('Ability Stats')
@export var bullet_speed:int = 600
@export var bullet_damage:float = 1
@export var attack_speed:float = 1
@export var bullet_peirce:bool = false
@export var bullet_scale:float = 1
@export var bullet_spread:float = 0
@export var bullets_shot:int = 1
