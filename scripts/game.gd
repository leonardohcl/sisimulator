extends Node
class_name Game

var ellapsed_seconds := 0

@onready var sisyphus: Node2D = $Sisyphus
@onready var bolder: Bolder = $Bolder
@onready var mountain: Mountain = $Mountain
@onready var average_label: Label = %"Average Label"
@onready var time_label: Label = %"Time Label"

func _ready() -> void:
	_generate_rand_event()
	
	_update_average_label()
	PushCounter.cycle_ended.connect(_update_average_label)
	_start_time_tracking()
	mountain.slope_created.connect(_handle_new_slope_creates)

func _game_over():
	sisyphus.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

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
	print("sisyphus has a thought")
	
func _generate_rand_event():
	# remove later:
	await get_tree().create_timer(3).timeout
	
	var events = [_start_rain, _receive_energy, _set_bird, _thought] #_cerberus, _persephone, _orpheus, _sleep, _reach_top]
	await events.pick_random().call()
	_generate_rand_event()

## Does something when a new mountain section (Slope) is created
func _handle_new_slope_creates(slope:Slope):
	pass

