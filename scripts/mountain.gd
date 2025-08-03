extends Node2D
class_name Mountain
@export var max_slopes := 10
@export_category("Slopes Settings")
@export var blocks_count := 3
@export var plateau_size := 300.0
@export var min_block_size := 100.0
@export var max_block_size := 300.0
@export var min_block_angle := 15.0
@export var max_block_angle := 45.0

signal slope_created(slope:Slope)

var slopes: Array[Slope]
var thresholds_count := 0

func _ready() -> void:
	generate()

func generate():
	slopes = []
	thresholds_count = 0
	for child in get_children():
		child.queue_free()
	await _generate_slope(true, false)
	for x in max_slopes - 1:
		await _generate_slope()
		
func _generate_slope(is_plateau := false, allow_events := true):
	if slopes.size() >= max_slopes:
		_remove_oldest_slope()
	
	var slope = preload("res://scenes/slope.tscn").instantiate() as Slope
	if is_plateau:
		slope.blocks_count = 1
		slope.min_block_size = plateau_size
		slope.max_block_size = plateau_size
		slope.min_block_angle = 0
		slope.max_block_angle = 0
	else:
		slope.blocks_count = blocks_count
		slope.min_block_size = min_block_size
		slope.max_block_size = max_block_size
		slope.min_block_angle = min_block_angle
		slope.max_block_angle = max_block_angle
	
	slope.allow_events = allow_events
	if slopes.size():
		slope.position = slopes[-1].position + slopes[-1].last_point()
		
	slope.reached_threshold.connect(_handle_slope_threshold_reached)
	slopes.append(slope)
	call_deferred("add_child", slope)
	await slope.ready
	slope_created.emit(slope)

func _remove_oldest_slope():
	slopes.pop_front().queue_free()

func _handle_slope_threshold_reached():
	thresholds_count += 1
	if thresholds_count >= 0.8 * max_slopes:
		_generate_slope()
		thresholds_count = 0
	
