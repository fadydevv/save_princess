extends CharacterBody2D

@export var max_health: int = 100
@export var move_speed: float = 150.0
@export var attack_damage: int = 10
@export var invincibility_duration: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: ProgressBar = $ProgressBar

var current_health: int
var last_direction: String = "down"
var is_invincible: bool = false
var is_attacking: bool = false
var is_hurt: bool = false

func _ready():
	current_health = max_health
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health

func _physics_process(_delta):
	if is_hurt or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		perform_attack()
		return

	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * move_speed
	move_and_slide()
	
	update_animation(input_direction)

func perform_attack():
	is_attacking = true
	velocity = Vector2.ZERO

	_align_attack_area()

	if animated_sprite.sprite_frames.has_animation("attack_" + last_direction):
		animated_sprite.play("attack_" + last_direction)
	elif animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")

	if attack_area != null:
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body != self and body.has_method("take_damage"):
				body.take_damage(attack_damage)

	await animated_sprite.animation_finished
	is_attacking = false

func _align_attack_area():
	if attack_area == null:
		return

	match last_direction:
		"up": attack_area.position = Vector2(0, -20)
		"down": attack_area.position = Vector2(0, 20)
		"left": attack_area.position = Vector2(-20, 0)
		"right": attack_area.position = Vector2(20, 0)

func update_animation(direction: Vector2):
	if is_hurt or is_attacking:
		return

	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "down" if direction.y > 0 else "up"
			
		animated_sprite.play("walk_" + last_direction)
	else:
		animated_sprite.play("idle_" + last_direction)

func take_damage(amount: int):
	if is_invincible or current_health <= 0:
		return

	current_health -= amount
	_update_health_bar()

	if current_health <= 0:
		die()
		return

	is_invincible = true
	is_hurt = true

	var hit_anim = "hurt_" + last_direction
	if animated_sprite.sprite_frames.has_animation(hit_anim):
		animated_sprite.play(hit_anim)
		await animated_sprite.animation_finished

	is_hurt = false
	_flash_effect()

	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false
	animated_sprite.modulate.a = 1.0

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	_update_health_bar()

func _update_health_bar():
	if health_bar != null:
		health_bar.value = current_health

func _flash_effect():
	while is_invincible:
		animated_sprite.modulate.a = 0.3
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout

func die():
	var end_screen = get_tree().get_first_node_in_group("end_screen")
	if end_screen != null:
		end_screen.show_end_screen("YOU DIED")
	else:
		get_tree().reload_current_scene()
