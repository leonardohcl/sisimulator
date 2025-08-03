extends RigidBody2D
class_name Bolder

@onready var sprite: Sprite2D = %Sprite

func set_imovable(is_imovable:bool):
	set_deferred("freeze", is_imovable)

func get_bird() -> Bird:
	for child in get_children():
		if child is Bird:
			return child
	return null
