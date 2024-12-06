extends Node

signal running_mode_entered
signal running_mode_ending
signal running_mode_ended
signal pacman_died

var score := 0
var lives := 3
var is_running_mode := false


func enter_running_mode() -> void:
	is_running_mode = true
	running_mode_entered.emit()
	await get_tree().create_timer(10).timeout
	running_mode_ending.emit()
	await get_tree().create_timer(5).timeout
	running_mode_ended.emit()
	is_running_mode = false


func eat_small_pellet() -> void:
	score += 2


func eat_large_pellet() -> void:
	score += 10
	enter_running_mode()


func eat_ghost() -> void:
	score += 100


func restart() -> void:
	score = 0
	lives = 3
	get_tree().reload_current_scene()
