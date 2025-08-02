extends CharacterBody2D
class_name Sisiphus

const GRAVITY_FORCE := 20.0

## Strength applied to collisions per push  
@export var strength := 30.0
@export var speed := 100.0

func _physics_process(_delta: float) -> void:
	_move()
	_apply_force_to_collisions()

func _move():
	var horizontal_force = strength * PushCounter.amount()
	velocity = Vector2(horizontal_force, GRAVITY_FORCE)
	move_and_slide()
	_apply_force_to_collisions()

func _apply_force_to_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var node = collision.get_collider()
		if node is Bolder:
			node.apply_central_impulse(-collision.get_normal() * strength)
