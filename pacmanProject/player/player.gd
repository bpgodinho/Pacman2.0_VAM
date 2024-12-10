class_name Player
extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}

@export var speed := 100

var facing_direction := Direction.LEFT
var previous_direction := Vector2.LEFT
var start_position: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var eat_ghost_sound: AudioStreamPlayer = $EatGhostSound


func _ready() -> void:
	animated_sprite_2d.play("left")
	start_position = position


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		facing_direction = Direction.DOWN
		animated_sprite_2d.play("down")
	elif event.is_action_pressed("up"):
		facing_direction = Direction.UP
		animated_sprite_2d.play("up")
	elif event.is_action_pressed("left"):
		facing_direction = Direction.LEFT
		animated_sprite_2d.play("left")
	elif event.is_action_pressed("right"):
		facing_direction = Direction.RIGHT
		animated_sprite_2d.play("right")
	elif event.is_action_pressed("ui_up"):
		print(global_position)


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	
	match facing_direction:
		Direction.DOWN:
			direction.y = 1
		Direction.UP:
			direction.y = -1
		Direction.LEFT:
			direction.x = -1
		Direction.RIGHT:
			direction.x = 1
	
	velocity = direction
	
	var collision := move_and_collide(velocity * speed * delta)
	if collision:
		if collision.get_collider() is CharacterBody2D:
			# Collided with ghost
			collided_with_ghost(collision.get_collider())
		else:
			move_and_collide(previous_direction * speed * delta)
	else:
		previous_direction = direction


func collided_with_ghost(ghost: Node2D) -> void:
	if GameManager.is_running_mode:
		ghost.kill()
		GameManager.eat_ghost()
		eat_ghost_sound.play()
	else:
		die()


func die() -> void:
	animated_sprite_2d.pause()
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 2)
	tween.tween_callback(_restart)
	process_mode = Node.PROCESS_MODE_DISABLED
	
	death_sound.play()
	GameManager.lives -= 1
	if GameManager.lives < 0:
		# Check if this score is highscore
		if GameManager.score > SaveSystem.data.highscore:
			SaveSystem.data.highscore = GameManager.score
			SaveSystem.save_game()
		GameManager.restart()
		get_tree().change_scene_to_file("res://menu.tscn")


func _restart() -> void:
	modulate = Color.WHITE
	position = start_position
	process_mode = PROCESS_MODE_INHERIT
	animated_sprite_2d.play("left")
	facing_direction = Direction.LEFT
	GameManager.pacman_died.emit()
