extends Area2D

@export var destination: Node2D


func _on_area_entered(area: Area2D) -> void:
	area.global_position = destination.global_position


func _on_body_entered(body: Node2D) -> void:
	body.global_position = destination.global_position
