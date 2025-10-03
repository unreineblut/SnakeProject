extends CharacterBody2D

# -------------------------------
# Estados de la serpiente
# -------------------------------
enum State { MENU, PLAYING, GAME_OVER }
var state: State = State.MENU

# -------------------------------
# Movimiento
# -------------------------------
@export var segment_size: int = 16       # Tamaño del grid
@export var speed: float = 0.15          # Tiempo entre pasos
var direction: Vector2 = Vector2.RIGHT
var next_direction: Vector2 = Vector2.RIGHT

# -------------------------------
# Cuerpo y posiciones
# -------------------------------
var body_segments: Array = []            # Segmentos instanciados
var positions_history: Array = []        # Historial de posiciones de la cabeza

# -------------------------------
# Referencias
# -------------------------------
@onready var body_container: Node2D = $Body
@onready var move_timer: Timer = $MoveTimer

# -------------------------------
# Inicialización
# -------------------------------
func _ready():
	move_timer.wait_time = speed
	move_timer.start()
	move_timer.connect("timeout", Callable(self, "_on_move_timer_timeout"))
	reset()  # Inicia la serpiente

# -------------------------------
# Input de jugador
# -------------------------------
func _process(delta):
	handle_input()

func handle_input():
	# Cambia dirección según input, evita giro 180°
	if Input.is_action_just_pressed("ui_up") and direction != Vector2.DOWN:
		next_direction = Vector2.UP
	elif Input.is_action_just_pressed("ui_down") and direction != Vector2.UP:
		next_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left") and direction != Vector2.RIGHT:
		next_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right") and direction != Vector2.LEFT:
		next_direction = Vector2.RIGHT

# -------------------------------
# Movimiento suave basado en historial
# -------------------------------
func _on_move_timer_timeout():
	if state != State.PLAYING:
		return

	direction = next_direction

	# Guardar la posición actual de la cabeza
	positions_history.insert(0, global_position)

	# Mover cabeza
	global_position += direction * segment_size

	# Actualizar cada segmento para seguir suavemente
	for i in range(body_segments.size()):
		var target_pos = positions_history[(i + 1) * int(segment_size / 1)]
		if target_pos:
			body_segments[i].global_position = target_pos

	# Limitar historial al tamaño necesario
	var max_history = (body_segments.size() + 1) * int(segment_size / 1)
	positions_history = positions_history.slice(0, max_history)

	# Verificar colisiones
	check_collisions()

# -------------------------------
# Crecimiento de la serpiente
# -------------------------------
func grow():
	var segment = Sprite2D.new()
	segment.texture = $Head.texture  # Opcional: usar mismo sprite de cabeza
	segment.global_position = global_position
	body_container.add_child(segment)
	body_segments.append(segment)

# -------------------------------
# Reiniciar la serpiente
# -------------------------------
func reset():
	# Limpiar segmentos existentes
	for segment in body_segments:
		segment.queue_free()
	body_segments.clear()
	positions_history.clear()
	global_position = Vector2(200, 200)  # Posición inicial
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	state = State.MENU
	move_timer.start()

# -------------------------------
# Colisiones
# -------------------------------
func check_collisions():
	# Colisión con el propio cuerpo
	for segment in body_segments:
		if segment.global_position == global_position:
			game_over()

	# Colisión con bordes de la pantalla
	var screen_rect = get_viewport_rect()
	if global_position.x < 0 or global_position.y < 0 or global_position.x > screen_rect.size.x or global_position.y > screen_rect.size.y:
		game_over()

# -------------------------------
# Game over
# -------------------------------
func game_over():
	state = State.GAME_OVER
	move_timer.stop()
	print("GAME OVER")
