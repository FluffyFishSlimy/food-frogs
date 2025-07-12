extends CanvasLayer
@onready var transition: ColorRect = $transition

func _ready() -> void:
	transition.show()
