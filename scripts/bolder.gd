extends RigidBody2D
class_name Bolder

@onready var sprite: Sprite2D = %Sprite


func set_imovable(is_imovable:bool):
	set_deferred("freeze", is_imovable)
