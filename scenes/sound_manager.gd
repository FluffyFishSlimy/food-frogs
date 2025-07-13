extends Node
@onready var main_menu: AudioStreamPlayer = $main_menu

func _ready() -> void:
	data.start_game.connect(main_game_music)

func main_game_music():
	main_menu.stop()
	play_sound('game_music', 1, -15)

func play_sound(sound, pitch, vol):
	#print('Playing Sound: ' + sound)
	var soundplayer = find_child(sound)
	#print('Soundplayer: ' + str(soundplayer))
	if soundplayer == null:
		printerr('SoundManager Error: Couldnt Find Sound')
	else:
		soundplayer.pitch_scale = pitch
		soundplayer.volume_db = vol
		soundplayer.play()
		soundplayer.pitch_scale = 1
