extends Marker2D
class_name SpawnSnake
## Nodo de tipo Marker2D que define el punto de reaparición (spawn) de la serpiente.
## Conectado al GameManager para manejar la aparición y eliminación del Player.

# --- Export: referencia a la escena del Player ---
@export var player_scene: PackedScene

# --- Referencia interna al jugador instanciado ---
var player_instance: CharacterBody2D = null

# --- Referencia al GameManager (autoload) ---
var game_manager: Node = null


func _ready() -> void:
	# Buscar GameManager en la raíz
	game_manager = get_node("/root/GameManager")
	
	# Conectar señales del GameManager
	game_manager.game_started.connect(_on_game_started)
	game_manager.game_over.connect(_on_game_over)
	game_manager.game_paused.connect(_on_game_paused)
	game_manager.game_resumed.connect(_on_game_resumed)


# --- API ---
func spawn_player() -> CharacterBody2D:
	"""
	Instancia un nuevo Player en la posición del Marker2D.
	Si ya existe un jugador, lo elimina primero.
	"""
	if player_instance and is_instance_valid(player_instance):
		player_instance.queue_free()
		player_instance = null
	
	if player_scene:
		player_instance = player_scene.instantiate() as CharacterBody2D
		get_tree().current_scene.add_child(player_instance)
		player_instance.global_position = global_position
		return player_instance
	
	push_warning("No se asignó ninguna escena de Player en SpawnSnake.")
	return null


func reset_player() -> void:
	"""
	Reubica el jugador en la posición de spawn y llama a su método reset().
	"""
	if player_instance and is_instance_valid(player_instance):
		player_instance.global_position = global_position
		if player_instance.has_method("reset"):
			player_instance.reset()


func remove_player() -> void:
	"""
	Elimina al jugador actual.
	"""
	if player_instance and is_instance_valid(player_instance):
		player_instance.queue_free()
		player_instance = null


# --- Señales del GameManager ---
func _on_game_started() -> void:
	spawn_player()

func _on_game_over() -> void:
	remove_player()

func _on_game_paused() -> void:
	# Aquí podrías pausar animaciones del Player si fuera necesario
	pass

func _on_game_resumed() -> void:
	# Aquí podrías reanudar animaciones del Player si fuera necesario
	pass
