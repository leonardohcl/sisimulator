extends Node

## How long it will acumulate pushes (seconds)
var _pushed := 0
var _total_pushes := 0
var _timer: Timer
var _cycles := 0

signal cycle_ended()
signal push_added()

func amount() -> int:
	return _pushed

func average() -> float:
	if !_cycles: return 0
	return float(_total_pushes)/float(_cycles)

func _ready() -> void:
	_create_timer()

func _create_timer():
	_timer = Timer.new()
	_timer.autostart = true
	_timer.wait_time = 1.0
	_timer.one_shot = false
	_timer.timeout.connect(_finish_cycle)
	add_child(_timer)	
	
func _listen_to_push():
	if Input.is_action_just_pressed("Push"):
		_pushed += 1
		_total_pushes += 1
		push_added.emit()

func _process(_delta: float) -> void:
	_listen_to_push()

func _finish_cycle():
	_pushed = 0
	_cycles += 1
	cycle_ended.emit()
