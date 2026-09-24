extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		var end_screen = get_tree().get_first_node_in_group("end_screen")
		if end_screen != null:
			end_screen.show_end_screen("YOU SAVED THE PRINCESS!")
