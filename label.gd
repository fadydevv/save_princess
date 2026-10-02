extends Label

func _ready() -> void:
	text = "0"
	GameManager.score_updated.connect(_score_updated)

func _score_updated(new_score: int) -> void:
	text = str(new_score)
