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
			sisyphus.think("Were they drinking just... water?", 3.5)

func animate_bird(is_arriving: bool):
	var duration = 1.0
	set_paused(true)
	if is_arriving:
		var bird = preload("res://scenes/bird.tscn").instantiate() as Bird
		bird.set_flying(true)
		bird.position = Vector2(get_viewport().get_visible_rect().size.x, -get_viewport().get_visible_rect().size.y).rotated(-bolder.rotation)
		bird.rotation = -bolder.rotation
		bolder.add_child(bird)
		var tween = get_tree().create_tween()
		tween.tween_property(bird, "position", Vector2(0, -50).rotated(-bolder.rotation), duration)
		await tween.finished
		bird.set_flying(false)
	else:
		print("bird flew")
		var bird = bolder.get_bird()
		if bird:
			bird.set_flying(true)
			var tween = get_tree().create_tween()
			tween.tween_property(bird, "position", -get_viewport().get_visible_rect().size.rotated(-bolder.rotation), duration)
			await tween.finished
			bird.queue_free()
	set_paused(false)

func _set_bird():
	bolder.set_imovable(true)
	await animate_bird(true)
	for i in 4:
		await sisyphus.pushed
		var bird = bolder.get_bird()
		if bird: 
			bird.set_flying(true)
			await get_tree().create_timer(0.4).timeout
			bird.set_flying(false)
		
	await animate_bird(false)
	bolder.set_imovable(false)

func _set_zagreus():
	# animate? (show asset)
	# Minha ideia era colocar um sprite ao lado e
	# o balao de pensamento igual do sisyphus
	dialog_manager.write("Underworld Prince", " Keep on keeping up")

func _thought():
	var thoughts = [
		"Did I lock the door back at home?",
		"Did I leave my water bottle at the bottom of the hill?",
		"Am I getting stronger, or is the boulder just getting lighter?",
		"Is this even a good workout? Shouldn't I be doing more squats or something?",
		"I wonder what the three headed dog's doing right now...",
		"Wait, am I actually getting any closer to the top?",
	] 
	
	sisyphus.think(thoughts[randi_range(0, thoughts.size() - 1)], 5)
	
func _generate_rand_event() -> Callable:
	var events = [
		#_start_rain, 
		_receive_energy, 
		_set_bird, 
		_thought,
		_set_zagreus,
		_restart
	] #_cerberus, _persephone, _orpheus]
	return events.pick_random()

## Does something when a new mountain section (Slope) is created
func _handle_new_slope_created(slope:Slope):
	if !slope.allow_events: return
	var event = _generate_rand_event()
	var trigger = slope.add_trigger_at(randf())
	trigger.triggered.connect(event)
	if event == _receive_energy:
		var lost_soul = preload("res://scenes/lost-soul.tscn").instantiate()
		lost_soul.position = Vector2(10,10)
		trigger.add_child(lost_soul)
	elif event == _set_zagreus:
		var zag = preload("res://scenes/zag.tscn").instantiate()
		zag.position = Vector2(10,10)
		trigger.add_child(zag)

func _on_start_game_button_pressed() -> void:
	$"UI/Menu/VBoxContainer/Start Game Button".disabled = true
	var duration = 2.0
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(menu, "modulate", Color(0,0,0,0), duration)
	tween.parallel().tween_property(camera, "global_position", sisyphus.global_position, duration)
	await tween.finished
	camera.reparent(bolder)
	camera.position = Vector2.ZERO
	menu.visible = false
	set_paused(false)

func _restart():
	var duration = 2.0
	var overlay = $UI/Darkness
	overlay.visible = true
	overlay.modulate = Color(0,0,0,0)
	sisyphus.set_sprite(Sisiphus.ANIMATION.Stand)
	sisyphus.process_mode = Node.PROCESS_MODE_DISABLED
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "modulate", Color(0,0,0,1), duration)
	await tween.finished
	set_paused(true)
	await mountain.generate()
	sisyphus.global_position = Vector2(34, 431)	
	bolder.global_position = Vector2(200, 400)
	tween = get_tree().create_tween()
	tween.tween_property(overlay, "modulate", Color(0,0,0,0), duration)
	await tween.finished
	sisyphus.process_mode = Node.PROCESS_MODE_INHERIT
	sisyphus.set_sprite(Sisiphus.ANIMATION.Idle)
	overlay.visible = false
	set_paused(false)
	
