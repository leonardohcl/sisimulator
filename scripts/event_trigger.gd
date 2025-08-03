extends Area2D
class_name EventTrigger

var activation_trigger_radius := 25
var trigger_with_bolder := true
var destroy_on_trigger := true

signal triggered()

func _ready():
	_create_collider()
	_setup_collision_detection()

func _create_collider():
	var collider = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = activation_trigger_radius
	collider.shape = shape
	add_child(collider)

func _setup_collision_detection():
	set_collision_layer_value(1,false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	body_entered.connect(_handle_body_entered)

func _handle_body_entered(body:Node2D):
	var is_triggered =  (body is Bolder and trigger_with_bolder) or body is Sisiphus
	if is_triggered: 
		triggered.emit()
		if destroy_on_trigger:
			queue_free()
