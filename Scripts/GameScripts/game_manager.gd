extends Node

# --- Estados del juego ---
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

# --- Señales ---
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal tick                # se emite en cada "paso" del juego
signal state_changed(old_state: int, new_state: int)

# --- Configuración ---
@export var initial_step_interval: float = 0.20   # tiempo entre ticks (segundos)
@export var min_step_interval: float = 0.05       # velocidad máxima
@export var speed_multiplier_on_food: float = 0.95

# --- Estado interno ---
var state: GameState = GameState.MENU
var score: int = 0

# --- Timer para ticks ---
@onready var tick_timer: Timer = Timer.new()

func _ready() -> void:
	# Añadimos el timer al singleton
	add_child(tick_timer)
	tick_timer.one_shot = false
	tick_timer.autostart = false
	tick_timer.wait_time = initial_step_interval
	tick_timer.timeout.connect(_on_tick)

# --- API pública ---
func start_game() -> void:
	score = 0
	tick_timer.wait_time = initial_step_interval
	tick_timer.start()
	_change_state(GameState.PLAYING)
	emit_signal("game_started")

func pause_game() -> void:
	if state != GameState.PLAYING: return
	tick_timer.stop()
	_change_state(GameState.PAUSED)
	emit_signal("game_paused")

func resume_game() -> void:
	if state != GameState.PAUSED: return
	tick_timer.start()
	_change_state(GameState.PLAYING)
	emit_signal("game_resumed")

func end_game() -> void:
	tick_timer.stop()
	_change_state(GameState.GAME_OVER)
	emit_signal("game_over")

# --- Tick principal ---
func _on_tick() -> void:
	if state == GameState.PLAYING:
		emit_signal("tick") # los sistemas (Snake, MapManager) escuchan este tick

# --- Aumentar puntuación y acelerar ---
func add_score(points: int = 1) -> void:
	score += points
	tick_timer.wait_time = max(min_step_interval, tick_timer.wait_time * speed_multiplier_on_food)

# --- Interno: cambio de estado ---
func _change_state(new_state: GameState) -> void:
	if state == new_state: return
	var old_state = state
	state = new_state
	emit_signal("state_changed", old_state, new_state)
