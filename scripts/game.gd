extends Node
class_name Game

var ellapsed_seconds := 0

@onready var sisyphus: Node2D = %Sisyphus
@onready var bolder: Bolder = %Bolder
@onready var mountain: Mountain = %Mountain
@onready var average_label: Label = %"Average Label"
@onready var time_label: Label = %"Time Label"
@onready var dialog_manager:DialogManager = %"Dialog Manager"
@onready var camera: Camera2D = $Camera
@onready var menu: CenterContainer = %Menu

func set_paused(is_paused := true):
	$"Game Core".set_deferred("process_mode", Node.PROCESS_MODE_DISABLED if is_paused else Node.PROCESS_MODE_INHERIT)

func _ready() -> void:
	_update_average_label()
	PushCounter.cycle_ended.connect(_update_average_label)
	_start_time_tracking()
	_start_dialog_handling()
	_start_mountain_control()
	set_paused(true)

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
	average_label.text = "%.1f push/s" % PushCounter.average()

func _add_second():
	ellapsed_seconds += 1
	time_label.text = "%ss" % ellapsed_seconds
	
func _start_rain():
	print("it's raining")
	sisyphus.think("Oh great...", 3.0)
	bolder.mass = 3.5
	await get_tree().create_timer(randi_range(2, 4)).timeout
	bolder.mass = 1
	
func _receive_energy():
	var ans = await dialog_manager.ask("Lost Soul", "Want a sip?", ["yes", "no"])
	if ans == 0:
		if randf() > 0.5:
			print("real redbull")
			sisyphus.think("By the gods! That was Nectar! I feel stronger!", 3.5)
			sisyphus.strength = 60
			await get_tree().create_timer(8).timeout
			sisyphus.strength = 30
			sisyphus.think("I think the effect of that Nectar is wearing off...", 3.5)
		else:
			print("fake redbull")
			sisyphus.think("He was drinking just... water?", 3.5)

func animate_bird(is_arriving: bool):
	if is_arriving:
		print("heavy ahh bird")
		var bird = Label.new()
		bird.text = "🐦‍"
		bolder.add_child(bird)
	else:
		print("bird flew")
		for child in bolder.get_children():
			if child is Label:
				child.queue_free()
		

func _set_bird():
	bolder.set_imovable(true)
	animate_bird(true)
	for i in 8:
		await PushCounter.push_added
	animate_bird(false)
	bolder.set_imovable(false)

func _set_zagreus():
	# animate? (show asset)
	# Minha ideia era colocar um sprite ao lado e
	# o balao de pensamento igual do sisyphus
	await dialog_manager.ask("Zagreus", "Hello Sisyphus! Keep on keeping up", ["close"])
	
	
func _thought():
	var thoughts = [
		"Did I lock the door back at home?",
		"Did I leave my water bottle at the bottom of the hill?",
		"Am I getting stronger, or is the boulder just getting heavier?",
		"Is this even a good workout? Shouldn't I be doing more squats or something?",
		"I wonder what the dog's doing right now...",
		"Wait, am I actually getting any closer to the top, or am I stuck in some weird loop?",
	] 
	
	sisyphus.think(thoughts[randi_range(0, len(thoughts))], 5)
	
func _generate_rand_event() -> Callable:
	var events = [
		_start_rain, 
		_receive_energy, 
		_set_bird, 
		_thought,
		_set_zagreus,
	] #_cerberus, _persephone, _orpheus, _sleep, _reach_top]
	return events.pick_random()

## Does something when a new mountain section (Slope) is created
func _handle_new_slope_created(slope:Slope):
	if !slope.allow_events: return
	var event = _generate_rand_event()
	var trigger = slope.add_trigger_at(randf())
	trigger.triggered.connect(event)


func _on_start_game_button_pressed() -> void:
	var duration = 2.0
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(menu, "modulate", Color(0,0,0,0), duration)
	tween.parallel().tween_property(camera, "global_position", sisyphus.global_position, duration)
	await tween.finished
	camera.reparent(bolder)
	camera.position = Vector2.ZERO
	menu.visible = false
	set_paused(false)
