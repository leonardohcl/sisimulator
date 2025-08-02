extends Node2D
class_name Mountain

@export var blocks_count := 10
@export var plateau_size := 400.0
@export var min_block_size := 100.0
@export var max_block_size := 300.0
@export var min_block_angle := 15.0
@export var max_block_angle := 45.0

@onready var collider: CollisionPolygon2D = %Collider
@onready var texture: Polygon2D = %Texture
@onready var goal_area: Area2D = %"Goal Area"
@onready var goal_collider: CollisionShape2D = %"Goal Collider"

signal reached_top()

func _ready() -> void:
	_generate_floor()

func _place_goal(last_point: Vector2):
	(goal_collider.shape as RectangleShape2D).size.x = plateau_size
	goal_collider.position.y = -(goal_collider.shape as RectangleShape2D).size.y * 0.5
	goal_area.global_position = to_global(last_point) - Vector2(plateau_size * 0.5, 0)
	
func _generate_floor():
	# starting plateau
	var points = [Vector2.ZERO, Vector2(plateau_size, 0)]
	
	# slope sections
	for x in blocks_count:
		var size = randf_range(min_block_size, max_block_size)
		var angle = -deg_to_rad(randf_range(min_block_angle, max_block_angle))
		var coords = points[-1] + Vector2(size, 0).rotated(angle)
		points.append(coords)
	
	# ending plateau
	points.append(points[-1] + Vector2(plateau_size, 0))
	
	var first_point = points[0]
	var last_point = points[-1]
	points.append(Vector2(last_point.x, first_point.y + 100))
	points.append(Vector2(first_point.x, first_point.y + 100))
	
	collider.polygon = points
	texture.polygon = points
	_place_goal(last_point)


func _on_goal_area_body_entered(body: Node2D) -> void:
	if body is Bolder:
		reached_top.emit()
