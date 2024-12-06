extends CharacterBody2D

const DIRECTIONS := [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]

enum GhostType {RED, YELLOW, PINK, ORANGE}
enum GhostMode {NORMAL, RUNNING, RUNNING_ENDING}

@export var type := GhostType.RED
@export var speed := 70
@export var release_time := 1
@export var eaten_time := 3

var ghost_color := "red"
var inside_cage := true
var mode := GhostMode.NORMAL
var direction := Vector2.UP
var start_position: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gate_detector: Area2D = $GateDetector


func _ready() -> void:
	GameManager.running_mode_entered.connect(_on_running_mode_entered)
	GameManager.running_mode_ending.connect(_on_running_mode_ending)
	GameManager.running_mode_ended.connect(_on_running_mode_ended)
	GameManager.pacman_died.connect(restart)
	
	start_position = global_position
	ghost_color = _get_color()
	await get_tree().create_timer(release_time).timeout
	_release_ghost()


func _process(delta: float) -> void:
	match mode:
		GhostMode.NORMAL:
			ghost_color = _get_color()
		GhostMode.RUNNING:
			ghost_color = "blue"
		GhostMode.RUNNING_ENDING:
			ghost_color = "flash"
	
	var animation_name := ghost_color + "_" + _get_direction_name()
	animated_sprite_2d.play(animation_name)


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	
	if collision:
		if collision.get_collider() is Player:
			collision.get_collider().collided_with_ghost(self)
		
		direction = _get_next_direction()


func _get_color() -> String:
	match type:
		GhostType.RED:
			return "red"
		GhostType.YELLOW:
			return "yellow"
		GhostType.PINK:
			return "pink"
		_:
			return "orange"


func _get_direction_name() -> String:
	if direction == Vector2.UP:
		return "up"
	elif direction == Vector2.DOWN:
		return "down"
	elif direction == Vector2.LEFT:
		return "left"
	else:
		return "right"


func _release_ghost() -> void:
	set_collision_mask_value(5, false)
	gate_detector.monitoring = true


func _get_next_direction() -> Vector2:
	if inside_cage:
		if direction == Vector2.DOWN:
			return Vector2.UP
		else: 
			return Vector2.DOWN
	else:
		return DIRECTIONS.pick_random()

func _on_gate_detector_body_exited(body: Node2D) -> void:
	inside_cage = false
	set_collision_mask_value(5, true)


func kill() -> void:
	global_position = start_position
	direction = Vector2.UP
	inside_cage = true
	set_collision_mask_value(5, true)
	await get_tree().create_timer(eaten_time).timeout
	_release_ghost()


func restart() -> void:
	global_position = start_position
	direction = Vector2.UP
	inside_cage = true
	set_collision_mask_value(5, true)
	await get_tree().create_timer(release_time).timeout
	_release_ghost()


func _on_running_mode_entered() -> void:
	mode = GhostMode.RUNNING


func _on_running_mode_ending() -> void:
	mode = GhostMode.RUNNING_ENDING


func _on_running_mode_ended() -> void:
	mode = GhostMode.NORMAL
