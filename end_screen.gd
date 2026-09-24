extends CanvasLayer

@onready var title_label: Label = $Control/VBoxContainer/TitleLabel
@onready var restart_button: Button = $Control/VBoxContainer/RestartButton

func _ready():
	hide()
	
	process_mode = PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart_pressed)

func show_end_screen(message: String):
	title_label.text = message
	show()
	get_tree().paused = true 
func _on_restart_pressed():
	get_tree().paused = false 
	GameManager.reset_score()
	get_tree().reload_current_scene()
