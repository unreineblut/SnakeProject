extends Node2D

@onready var player: Node = $Player
@export var food_scene: PackedScene 

func _ready():
	spawn_food()
	player.state = player.State.MENU
	player.move_timer.start()
	player.connect("grow", Callable(self, "_on_player_grow"))

func spawn_food():
	var food = food_scene.instantiate()
	food.position = Vector2(randi() % 20 * 16, randi() % 15 * 16)  # Grid de 16px
	add_child(food)
	food.connect("food_eaten", Callable(self, "_on_food_eaten"))

func _on_food_eaten():
	player.grow()
	spawn_food()
