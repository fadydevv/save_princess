extends Label

func _ready() -> void:
	text = "0"
	GameManager.score_updated.connect(_on_score_updated)

func _on_score_updated(new_score: int) -> void:
	text = str(new_score)
