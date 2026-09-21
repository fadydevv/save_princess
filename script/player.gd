extends CharacterBody2D

@export var move_speed : float = 150.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: String = "down"

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * move_speed
	move_and_slide()
	
	update_animation(input_direction)

func update_animation(direction: Vector2):
	if direction != Vector2.ZERO:
		# Choose horizontal vs vertical direction based on larger input value
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "down" if direction.y > 0 else "up"
			
		animated_sprite.play("walk_" + last_direction)
	else:
		animated_sprite.play("idle_" + last_direction)
