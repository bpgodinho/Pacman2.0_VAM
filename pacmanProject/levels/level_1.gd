extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var player: CharacterBody2D = $Player
@onready var siren_sound: AudioStreamPlayer = $SirenSound
@onready var running_sound: AudioStreamPlayer = $RunningSound
@onready var eat_sound: AudioStreamPlayer = $EatSound


func _ready() -> void:
	GameManager.running_mode_entered.connect(_on_running_mode_entered)
	GameManager.running_mode_ended.connect(_on_running_mode_ended)


func _physics_process(delta: float) -> void:
	var local_position := tile_map_layer.to_local(player.global_position)
	var cell := tile_map_layer.local_to_map(local_position)
	var data := tile_map_layer.get_cell_tile_data(cell)
	
	if not data:
		return
	
	if data.get_custom_data("small_pellet"):
		GameManager.eat_small_pellet()
		tile_map_layer.erase_cell(cell)
		if not eat_sound.playing:
			eat_sound.play()
	elif data.get_custom_data("large_pellet"):
		GameManager.eat_large_pellet()
		tile_map_layer.erase_cell(cell)


func _on_running_mode_entered() -> void:
	running_sound.play()
	siren_sound.stop()


func _on_running_mode_ended() -> void:
	running_sound.stop()
	siren_sound.play()
