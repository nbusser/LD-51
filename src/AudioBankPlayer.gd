extends AudioStreamPlayer

@export var sounds = []
@export var no_erase = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(sounds)):
		sounds[i] = sounds[i]
		#sounds[i].set_loop(false)


func play_sound():
	if playing and no_erase:
		return

	if len(sounds) > 0:
		stream = sounds[randi() % len(sounds)]
		super.play()
	else:
		print('ERROR: no sound ', self)
