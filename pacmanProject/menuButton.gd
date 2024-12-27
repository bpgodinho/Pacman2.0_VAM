extends Button

@onready var player_sprite: AnimatedSprite2D = $playerSprite

@export var newscene: String
@export var level: int

func _ready() -> void:
	player_sprite.play("right")

func _on_mouse_entered() -> void:
	player_sprite.show()

func _on_mouse_exited() -> void:
	player_sprite.hide()

func _on_focus_entered() -> void:
	player_sprite.show()

func _on_focus_exited() -> void:
	player_sprite.hide()

func _on_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(player_sprite,"position:x", 157, 0.05)
	tween.tween_callback(change_level)

func change_level() -> void:
	get_tree().change_scene_to_file(newscene)
