extends CharacterBody2D

const CELL_SIZE = 16
var moveDelay : float = 0.15

var direction = Vector2.RIGHT
var next_direction = Vector2.RIGHT
var body_positions = []
var body_segments = []
var should_grow = false

@onready var timer = $MoveTimer
@onready var sprite = $Sprite2D

func _ready():
	name = "Player"
	position = Vector2(8, 8) * CELL_SIZE
	timer.wait_time = moveDelay
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	randomize()

func _process(_delta):
	handle_input()

func handle_input():
	if Input.is_action_pressed("ui_up") and direction != Vector2.DOWN:
		next_direction = Vector2.UP
	elif Input.is_action_pressed("ui_down") and direction != Vector2.UP:
		next_direction = Vector2.DOWN
	elif Input.is_action_pressed("ui_left") and direction != Vector2.RIGHT:
		next_direction = Vector2.LEFT
	elif Input.is_action_pressed("ui_right") and direction != Vector2.LEFT:
		next_direction = Vector2.RIGHT

func _on_timer_timeout():
	direction = next_direction
	var new_pos = position + direction * CELL_SIZE
	
	# Si se muerde a sí mismo, reinicia
	if ocupaPosicion(new_pos):
		get_tree().reload_current_scene()
		return
	
	# Actualizar cuerpo
	body_positions.insert(0, position)
	
	if should_grow:
		agregarSegmento(position)
		should_grow = false
	else:
		if body_positions.size() > body_segments.size():
			body_positions.pop_back()
	
	position = new_pos
	
	# Mover segmentos a las nuevas posiciones
	for i in range(body_segments.size()):
		body_segments[i].position = body_positions[i]

func agregarSegmento(pos):
	var seg = Sprite2D.new()
	seg.texture = sprite.texture
	seg.modulate = Color(0.8, 0.8, 0.8)
	seg.position = pos
	get_parent().add_child(seg)
	body_segments.append(seg)

func ocupaPosicion(pos: Vector2) -> bool:
	if pos == position:
		return true
	for p in body_positions:
		if p == pos:
			return true
	return false
