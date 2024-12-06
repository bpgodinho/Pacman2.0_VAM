extends CanvasLayer

@onready var life_1: TextureRect = %Life1
@onready var life_2: TextureRect = %Life2
@onready var life_3: TextureRect = %Life3
@onready var score: Label = %Score


func _process(delta: float) -> void:
	life_1.visible = GameManager.lives > 0
	life_2.visible = GameManager.lives > 1
	life_3.visible = GameManager.lives > 2
	score.text = str(GameManager.score) + " | " + str(SaveSystem.data.highscore)
