extends Area2D
func _ready():
	posicionarComida()
func posicionarComida():
	var celda_size = 16
	var min_col = 1
	var max_col = 30  # excluye la columna 0 y la 31
	var min_fila = 1
	var max_fila = 16  # excluye la fila 0 y la 17
	
	for intento in range(100):  # evita bucles infinitos
		var x = randi() % (max_col - min_col + 1) + min_col
		var y = randi() % (max_fila - min_fila + 1) + min_fila
		var nueva_pos = Vector2(x, y) * celda_size
	
		if not estaSobreCulebra(nueva_pos):
			position = nueva_pos
			break
	print("comida posicionada en %s" % position)

func estaSobreCulebra(pos: Vector2) -> bool:
	# Esto será reemplazado luego por un chequeo real
	return false


func _on_Comida_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		posicionarComida()
