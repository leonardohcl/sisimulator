extends Control
class_name DialogManager

@onready var title:Label = %Title
@onready var body:Label = %Body
@onready var close_button:Button = %"Close Button"
@onready var actions_wrapper:Control = %"Actions Wrapper"

signal dialog_opened()
signal dialog_closed()
signal question_answered(idx:int)

func _ready():
	_close_dialog()
	
func _close_dialog():
	visible = false
	dialog_closed.emit()

func _open_dialog():
	visible = true
	dialog_opened.emit()

func _clear_options():
	for child in actions_wrapper.get_children():
		if child != close_button:
			child.queue_free()

func write(display_name: String, content: String, allow_close := true):
	title.text = display_name
	body.text = content
	close_button.visible = allow_close
	_open_dialog()

func _answer_question(idx:int) -> int:
	question_answered.emit(idx)
	return idx

## Asks a question and returns a the index of the chosen option (requires await)
func ask(display_name: String, content: String, options: Array[String]) -> int:
	for idx in options.size():
		var btn = Button.new()
		btn.text = options[idx]
		btn.pressed.connect(func (): _answer_question(idx))
		actions_wrapper.add_child(btn)
	write(display_name, content, false)
	var answer = await question_answered
	_close_dialog()
	return answer
	
func _on_close_button_pressed():
	_close_dialog()
