extends CharacterBody2D
class_name Sisiphus

enum ANIMATION {
	Idle,
	Walk,
	Push,
	Stand
}

const GRAVITY_FORCE := 20.0

@onready var sprite: Sprite2D = %Sprite

## Strength applied to collisions per push  
@export var strength := 30.0
@export var speed := 100.0

var _is_in_slope := false
var _is_pushing := false

func think(content: String, duration := 5.0):
	if %"Tought Bubble".visible: return
	%"Tought Label".text = content
	%"Tought Bubble".visible = true
	await get_tree().create_timer(duration).timeout
	%"Tought Bubble".visible = false

func _update_sprite():
	var just_stopped = PushCounter.time_left_for_clear() > 0.9
	if _is_pushing:
		sprite.frame = ANIMATION.Push if PushCounter.amount() > 0 and !just_stopped else ANIMATION.Stand
	else:
		sprite.frame = ANIMATION.Walk if PushCounter.amount() > 0 else ANIMATION.Idle

func _process(_delta:float):
	_update_sprite()

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
			_is_pushing = true
		elif node is Ground:
			_is_in_slope = collision.get_angle() >= 0.1
		
