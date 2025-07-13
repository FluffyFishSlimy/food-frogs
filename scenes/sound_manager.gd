extends Node

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
