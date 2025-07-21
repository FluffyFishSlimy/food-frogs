extends Control
@onready var frog_words: Label = $Panel/frog_words
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var frog_sprite: TextureRect = $Panel/frog_sprite

var texts = [
	"Hi, my name is Sir Froggerton",
	"I am the leader of the frogs and unfortunatly we have been having some trouble with some bugs",
	"I am seeking your help, in our on going war!",
	"Dont worry though, Ill explain how the game works, its quite easy!",
	"This game is a sort of tower defense crafting game",
	"You can drag foods onto the frogs to give them special abilities and allow them to attack the bugs",
	"Foods can be mixed together to create stronger abilites",
	"All the crafting information you need is in the recipe book, you just have to discover it first",
	"To get more foods, you can purchase them in the shop!",
	"All right, thats it! Good luck. Bugs will be here soon, be prepared"
]
var voules = ["a", "e", "i", "o", "u", "y"]
var texts_index = 0
var animating = false

func animate_text(words):
	animating = true
	frog_words.visible_characters = 0
	frog_words.text = words
	for i in range(words.length()):
		if animating == false:
			frog_words.visible_characters = 100000000000
			break
		frog_words.visible_characters += 1
		for vow in voules:
			if words[i].to_lower() == vow:
				SoundManager.play_sound('button_press', randf_range(0.8, 1.2), -10)
				frog_squish()
		await get_tree().create_timer(0.01).timeout
	animating = false

func _ready() -> void:
	if data.done_tut == false:
		await get_tree().create_timer(1).timeout
		animation_player.play("open")
		await animation_player.animation_finished
		animate_text(texts[0])
	else:
		await get_tree().create_timer(2).timeout
		data.tut_done.emit()

func frog_squish():
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	#SoundManager.play_sound('squeak2', randf_range(0.8, 1.2), -10)
	if randi_range(0,1) == 0:
		t.tween_property(frog_sprite, "scale", Vector2(1,1.2), 0.1)
	else:
		t.tween_property(frog_sprite, "scale", Vector2(1.2,1), 0.1)
	t.chain().tween_property(frog_sprite, "scale", Vector2(1,1), 0.1)

func _on_button_pressed() -> void:
	if animating:
		animating = false
	else:
		texts_index += 1
		if texts_index > texts.size()-1:
			animation_player.play_backwards("open")
			data.done_tut = true
			await animation_player.animation_finished
			await get_tree().create_timer(2).timeout
			data.tut_done.emit()
		else:
			animate_text(texts[texts_index])
