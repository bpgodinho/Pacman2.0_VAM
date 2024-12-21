extends Node

signal running_mode_entered
signal running_mode_ending
signal running_mode_ended
signal pacman_died

var levels: Array[String] = ["res://menu.tscn","res://levels/level_1.tscn","res://levels/level_2.tscn","res://levels/level_3.tscn"]
var score := 0
var lives := 3
var is_running_mode := false
var level := -1

func enter_running_mode() -> void:
	is_running_mode = true
	running_mode_entered.emit()
	await get_tree().create_timer(10).timeout
	running_mode_ending.emit()
	await get_tree().create_timer(5).timeout
	running_mode_ended.emit()
	is_running_mode = false


func eat_small_pellet() -> void:
	grant_points(2)


func eat_large_pellet() -> void:
	grant_points(10)
	enter_running_mode()


func eat_ghost() -> void:
	grant_points(100)


func eat_bonus(points: int) -> void:
	grant_points(points)


func grant_points(points: int) -> void:
	score += points


func end_game() -> void:
	get_tree().change_scene_to_file(levels[level])
	level = wrapi(level + 1, 0,3) 
	pass


func restart() -> void:
	score = 0
	lives = 3
