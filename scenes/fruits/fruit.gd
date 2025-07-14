class_name Fruit
extends Resource

@export_category('Basic Info')
@export var name: String = 'Fruit Name'
@export var desc:String = "Fruit Description"
@export var fruit_sprite:CompressedTexture2D
@export var frog_color:Color
@export var belly_icon:CompressedTexture2D
@export var has_been_discovered:bool = false
@export var recipe_to_make:Recipe

@export_category('Ability Stats')
@export var bullet_speed:int = 600
@export var bullet_damage:float = 1
@export var attack_speed:float = 1
@export var bullet_peirce:bool = false
