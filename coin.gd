extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	animated_sprite.play("idle")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collision_shape.set_deferred("disabled", true)
		GameManager.add_score(1)
		animated_sprite.play("collected")
		await animated_sprite.animation_finished
		queue_free()
