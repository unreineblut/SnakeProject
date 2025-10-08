extends Area2D

signal food_eaten

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("food_eaten")
		queue_free()  # Se destruye la comida
