extends Node2D
class_name Slope

@export var blocks_count := 10
@export var min_block_size := 100.0
@export var max_block_size := 300.0
@export var min_block_angle := 15.0
@export var max_block_angle := 45.0
@export var base_height := 600.0

@onready var end_area: Area2D = %"End Area"
@onready var texture: Polygon2D = %Texture
@onready var collider: CollisionPolygon2D = %Collider

signal reached_threshold()

var _points: Array[Vector2]
var allow_events := true

## Add an event trigger at closest point
## returns trigger node
func add_trigger_at(percentage: float, trigger_radius := 25.0, trigger_with_bolder := true, destroy_on_trigger := true) -> EventTrigger:
	if !allow_events: return
	var pos = clampf(percentage, 0, 1)
	var idx = clampi(round(_points.size() * pos) - 1, 0, _points.size() - 1)
	var trigger = EventTrigger.new()
	trigger.activation_trigger_radius = trigger_radius
	trigger.trigger_with_bolder = trigger_with_bolder
	trigger.position = _points[idx]
	trigger.destroy_on_trigger = destroy_on_trigger
	add_child(trigger)
	return trigger

func width():
	return last_point().x

func height():
	return last_point().y

func first_point():
	return _points[0]

func last_point() -> Vector2:
	return _points[-1]

func points() -> Array[Vector2]:
	return _points.map(func(v): return to_global(v))

func _ready() -> void:
	_generate()

func _generate():
	_points = [Vector2.ZERO]
	for x in blocks_count:
		var size = randf_range(min_block_size, max_block_size)
		var angle = -deg_to_rad(randf_range(min_block_angle, max_block_angle))
		var coords = last_point() + Vector2(size, 0).rotated(angle)
		_points.append(coords)
	
	end_area.position = _points[-2]
	
	var polygon = _points.duplicate()
	polygon.append(Vector2(last_point().x, base_height))
	polygon.append(Vector2(first_point().x, base_height))
	
	collider.polygon = polygon
	texture.polygon = polygon

func _on_end_area_body_entered(body: Node2D) -> void:
	if body is Sisiphus or body is Bolder:
		end_area.queue_free()
		reached_threshold.emit()
