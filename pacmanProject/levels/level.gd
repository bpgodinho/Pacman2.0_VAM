extends Node2D

const POWERUPS = [Vector2i(12,2),Vector2i(13,2),Vector2i(15,5),Vector2i(12,6),Vector2i(7,8)]

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var player: CharacterBody2D = $Player
@onready var siren_sound: AudioStreamPlayer = $SirenSound
@onready var running_sound: AudioStreamPlayer = $RunningSound
@onready var eat_sound: AudioStreamPlayer = $EatSound
@onready var powerup_timer: Timer = $PowerupTimer
@onready var powerup_kill_timer: Timer = $PowerupKillTimer

var free_cells = []
var current_powerup_tile: Vector2
var spawning := false
var eaten_pellets := 0
@export var total_pellets := 0

func _ready() -> void:
	GameManager.running_mode_entered.connect(_on_running_mode_entered)
	GameManager.running_mode_ended.connect(_on_running_mode_ended)


func _process(delta: float) -> void:
	if tile_map_layer.get_used_cells_by_id(-1,Vector2i(8,0)) == []:
		get_tree().change_scene_to_file("res://MainMenuButton.tscn")


func _physics_process(delta: float) -> void:
	var local_position := tile_map_layer.to_local(player.global_position)
	var cell := tile_map_layer.local_to_map(local_position)
	var data := tile_map_layer.get_cell_tile_data(cell)
	
	if free_cells.size() > 30 && !spawning:
		spawning = true
		powerup_timer.start()
	
	if not data:
		return
	
	if data.get_custom_data("small_pellet"):
		GameManager.eat_small_pellet()
		tile_map_layer.erase_cell(cell)
		free_cells.append(Vector2i(cell))
		eaten_pellets += 1
		if not eat_sound.playing:
			eat_sound.play()
	elif data.get_custom_data("large_pellet"):
		GameManager.eat_large_pellet()
		tile_map_layer.erase_cell(cell)
		free_cells.append(Vector2i(cell))
		eaten_pellets += 1
	elif  data.get_custom_data("extra_points") != 0:
		GameManager.eat_bonus(data.get_custom_data("extra_points"))
		tile_map_layer.erase_cell(cell)
		powerup_kill_timer.stop()
		powerup_timer.start()
		if not eat_sound.playing:
			eat_sound.play()


func _on_running_mode_entered() -> void:
	running_sound.play()
	siren_sound.stop()


func _on_running_mode_ended() -> void:
	running_sound.stop()
	siren_sound.play()


func _on_powerup_timer_timeout() -> void:
	print("powerup")
	if not free_cells.is_empty():
		var cell = free_cells.pick_random()
		tile_map_layer.set_cell(cell,0,POWERUPS.pick_random())
		current_powerup_tile = cell
		powerup_kill_timer.start()
	else:
		powerup_timer.start()


func _on_powerup_kill_timer_timeout() -> void:
	tile_map_layer.erase_cell(current_powerup_tile)
	powerup_timer.start()
