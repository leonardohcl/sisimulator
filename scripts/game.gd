extends Node
class_name Game

var ellapsed_seconds := 0

@onready var sisyphus: Node2D = $Sisyphus
@onready var bolder: Bolder = $Bolder
@onready var mountain: Mountain = $Mountain
@onready var average_label: Label = %"Average Label"
@onready var time_label: Label = %"Time Label"
@onready var dialog_manager:DialogManager = %"Dialog Manager"

func set_paused(is_paused := true):
	get_tree().paused = is_paused

func _ready() -> void:
	_update_average_label()
	PushCounter.cycle_ended.connect(_update_average_label)
	_start_time_tracking()
	_start_dialog_handling()
	_start_mountain_control()
	_thought()

func _start_mountain_control():
	mountain.slope_created.connect(_handle_new_slope_created)

func _game_over():
	sisyphus.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func _start_dialog_handling():
	dialog_manager.dialog_opened.connect(func(): set_paused(true))
	dialog_manager.dialog_closed.connect(func(): set_paused(false))
	#dialog_manager.write("name", "henlo world")
	#var ans = await dialog_manager.ask("?", "r u ok?", ['y', 'n'])

func _start_time_tracking():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_add_second)
	add_child(timer)
	
func _update_average_label():
	average_label.text = "%.1f pushes/cycle" % PushCounter.average()

func _add_second():
	ellapsed_seconds += 1
	time_label.text = "%ss" % ellapsed_seconds
	
func _start_rain():
	print("it's raining")
	bolder.mass = 3.5
	await get_tree().create_timer(randf_range(2, 3.75)).timeout
	bolder.mass = 1
	
func _receive_energy():
	if randf() > 0.5:
		print("real redbull")
		sisyphus.strength = 60
		await get_tree().create_timer(4).timeout
	else:
		print("fake redbull")
		# show failed msg?
		
func _set_bird():
	print("heavy ahh bird")
	bolder.mass = 5
	for i in 5:
		await PushCounter.push_added
	print("bird flew")
	bolder.mass = 1

func _thought():
	sisyphus.think("sisyphus has a thought", 3.0)
	
func _generate_rand_event() -> Callable:
	var events = [_start_rain, _receive_energy, _set_bird, _thought] #_cerberus, _persephone, _orpheus, _sleep, _reach_top]
	return events.pick_random()

## Does something when a new mountain section (Slope) is created
func _handle_new_slope_created(slope:Slope):
	if !slope.allow_events: return
	var event = _generate_rand_event()
	var trigger = slope.add_trigger_at(randf())
	trigger.triggered.connect(event)
