extends Node

var score: int = 0
signal score_updated(new_score: int)

func add_score(amount: int) -> void:
	score += amount
	score_updated.emit(score)

func reset_score() -> void:
	score = 0
	score_updated.emit(score)
