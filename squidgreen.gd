extends CharacterBody2D

@export var max_health: int = 100
@export var move_speed: float = 50.0
@export var detection_radius: float = 300.0
@export var stop_distance: float = 20.0

@export var attack_radius: float = 50.0
@export var attack_windup: float = 0.5
@export var attack_cooldown: float = 1.0
@export var damage: int = 15
@export var i_frame_duration: float = 0.4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_health: int
var player: Node2D = null
var can_attack: bool = true
var is_attacking: bool = false
var is_hurt: bool = false
var is_invincible: bool = false

func _ready():
	current_health = max_health
	_find_player()

func _find_player():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player == null:
		_find_player()
		return

	if is_hurt or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= detection_radius:
		if distance <= attack_radius:
			velocity = Vector2.ZERO
			if can_attack:
				perform_attack()
		elif distance > stop_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
			update_animation(direction)
		else:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

	move_and_slide()

func update_animation(direction: Vector2):
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
	animated_sprite.play("movement")

func perform_attack():
	is_attacking = true
	can_attack = false

	var direction = (player.global_position - global_position).normalized()
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

	animated_sprite.play("idle")
	await get_tree().create_timer(attack_windup).timeout

	if is_hurt or current_health <= 0:
		is_attacking = false
		_start_cooldown()
		return

	animated_sprite.play("attack")

	if player != null and global_position.distance_to(player.global_position) <= attack_radius + 15.0:
		if player.has_method("take_damage"):
			player.take_damage(damage)

	await animated_sprite.animation_finished
	is_attacking = false

	_start_cooldown()

func _start_cooldown():
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int):
	if is_invincible or current_health <= 0:
		return

	current_health -= amount

	if current_health <= 0:
		_on_squid_defeated()
		queue_free()
		return

	is_attacking = false
	is_hurt = true
	is_invincible = true

	animated_sprite.play("hurt")
	await animated_sprite.animation_finished
	is_hurt = false

	await get_tree().create_timer(i_frame_duration).timeout
	is_invincible = false

func _on_squid_defeated():
	var end_screen = get_tree().get_first_node_in_group("end_screen")
	if end_screen != null:
		end_screen.show_end_screen("YOU SAVED THE PRINCESS!")
